require 'net/ssh'
require 'net/scp'
class ImageJob
  include DebHelper
  #@queue = :error_server
  #
  @STATUS_ERROR = -1
  @STATUS_NOT_PROCESSED = 0
  @STATUS_IN_PROCESS = 1
  @STATUS_PROCESSED = 2
  #
  @hostname = "localhost"
  @username = "root"
  @password = "123"
  @remote_neural_path = "~/neural-style-master"
  @iteration_count = 10
  @local_tmp_path = '~/tmp/output'

  def initialize(worker_name)
    write_log "-----------------------Start Demon---------------------------"
    set_config(worker_name)
  end

  def set_config(worker_name)
    return if worker_name.nil?
    file = Rails.root.join('config/config.secret')
    config = get_param_config(file, :workservers, worker_name.to_sym)
    return if config.blank?
    #@queue = worker_name.to_sym
    @hostname = config["host"]
    @username = config["username"]
    @password = config["password"]
    @local_tmp_path = Rails.root.join('tmp/output')
    @remote_neural_path = config["remote_neural_path"]
    @iteration_count = config["iteration_count"]
    @init_params = config["init_params"] + " -num_iterations #{@iteration_count*100}" #  -output_image output/"
    @content_image_name = "content.jpg"
    @style_image_name = "style.jpg"
    ##debug
    config["password"] = "*"
    write_log "config: #{config.to_s}"
  end

  def execute
    #debug
    #send_start_process_comm()
    #return
    #
    write_log "-----------------------Execute Demon---------------------------"
    while true
      imgs = QueueImage.where("status = 0 ")
      if !imgs.nil? && imgs.count > 0 && !imgs.first.nil?
        item = imgs.first
        res = execute_image(item)
        if !res.nil?
          if res == "OK"
            item.update({:status => 2})
          else
            item.update({:status => -1, :result => res})
          end
        end
      else
        write_log "-----------------------Stop Demon---------------------------"
        return "Zero"
      end
      sleep 5
    end
  end

  def execute_image(item)
    return nil if item.nil?
    write_log "-----------------------"
    write_log "execute_image item.id = #{item.id}"
    #Change status to IN_PROCESS
    item.update({:status => 1})

    # Check connection to workserver
    return "get_server_name: false" if get_server_name.nil?

    # Clear remote tmp folger
    return "rm_file_on_server: false" unless rm_file_on_server

    #Upload images to workserver
    @content_image_name = "content.#{item.content_image.to_s.split('.').last}"
    @style_image_name = "style.#{item.style_image.to_s.split('.').last}"
    return "upload_content_image: false" unless upload_image(item.content_image, "output/#{@content_image_name}")
    return "upload_stule_image: false" unless upload_image(item.style_image, "output/#{@style_image_name}")
    #Run process
    send_start_process_comm()
    sleep 10
    # Wait processed images
    errors = wait_images()
    if errors.nil?
      "OK"
    else
      item.update({:result => errors})
      "wait_images: #{errors}"
    end
    #Change status to PROCESSED
    #item.status = @STATUS_PROCESSED
    #item.save
  end

  protected

  def check_neural_start
    write_log "check_neural_start"
    begin
      # Check error log
      rem = "#{@remote_neural_path}/output/error.log"
      loc = "#{@local_tmp_path}/error.log"
      Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
      if File.exist?(loc)
        str = File.read(loc)
        if !str.nil?
          return str if str.scan("error").size > 0
        end
      end
      # Check a output log
      rem = "#{@remote_neural_path}/output/output.log"
      loc = "#{@local_tmp_path}/output.log"
      Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
      return "No output log" unless File.exist?(loc)
      str = File.read(loc)
      if !str.nil?
        return str if str.scan("conv5_4").size == 0
      end
    rescue
      return "Error during download error.log and output.log"
    end
    nil
  end

  def wait_images

    iter = 1
    # Check remote neural process start
    res = check_neural_start
    write_log "DEBUG check_neural_start fail: #{res}" unless res.nil?
    return res unless res.nil?
    write_log "wait_images"
    #

    while true
      begin
        # Sent task for image
        rem = "#{@remote_neural_path}/output/output.log"
        loc = "#{@local_tmp_path}/output.log"
        Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
        break unless File.exist?(loc)
        str = File.read(loc)
        s = "Iteration #{iter}00"
        if !str.nil? && str.scan(s).size > 0
          save_image(iter)
          iter += 1
        end
      rescue

      end
      break if iter > @iteration_count
      sleep 2
    end
    nil
  end

  def save_image(iter_num)
    iter_num < @iteration_count ? name = "out_#{iter_num}00.png" : name = "out.png"
    download_image(name)
    loc =  "#{@local_tmp_path}/#{name}"
    file = File.read(loc)
    ImageMailer.send_image(iter_num, @iteration_count, file).deliver_now
    write_log "save_image: #{name}"
  end

  def get_server_name
    output = "1"
    Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
      output = ssh.exec!("hostname")
    end
    output
  end

  def rm_file_on_server
    begin
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        output = ssh.exec!("rm -rf #{@remote_neural_path}/output/*")
      end
    rescue
      return false
    end
    true
  end

  def download_image(filename)
    begin
      # Downloads files
      rem = "#{@remote_neural_path}/#{filename}"
      loc =  "#{@local_tmp_path}/#{filename}"
      Net::SCP.download!(@hostname, @username, rem, loc, :password => @password )
    rescue
      return false
    end
    true
  end

  def upload_image(loc_file_name, remote_file_name)
    begin
      # Downloads files
      rem = "#{@remote_neural_path}/#{remote_file_name}"
      loc =  Rails.root.join("public#{loc_file_name}") #"/home/matthew/input.png"#
      return false if !File.exist?(loc)
      Net::SCP.upload!(@hostname, @username,loc.to_s,rem, :password => @password)
      return true
    rescue

    end
    false
  end

  def create_n_upload_script
    rem = "#{@remote_neural_path}/neural.sh"
    loc =  Rails.root.join("config/neural.sh")

    if File.exist?(loc)
      begin
        scr = File.read(loc)
        com = "th neural_style.lua #{@init_params} -style_image output/#{@style_image_name} -content_image output/#{@content_image_name} > output/output.log 2> output/error.log &"
        scr << com
        Net::SCP.upload!(@hostname, @username, StringIO.new(scr), rem, :password => @password)
        return true
      rescue

      end
    end
    false
  end

  def send_start_process_comm
    write_log "send_start_process_comm"
    if create_n_upload_script
      begin
        Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
          comm = "cd #{@remote_neural_path} && chmod 777 neural.sh && ./neural.sh"
          comm += " "
          @conn = ssh.exec!(comm)
        end
        return true
      rescue

      end
    end
    false
  end






  #def self.perform(config)
  # @hostname = config["host"]
  # @username = config["username"]
  # @password = config["password"]
  # @local_tmp_path = "/home/matthew/RubymineProjects/ostagram/tmp/output"#Rails.root.join('tmp/output')
  # @remote_neural_path = "/home/margo/neural-style-master"#config["remote_neural_path"]
  # @iteration_count = 5
  #
  #self.execute()
  # end
  def process_image1
    comm = "cd #{@remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin && export LD_LIBRARY_PATH=/home/margo/torch/install/lib"
    comm += " && th neural_style.lua -gpu -1 -image_size 500 -num_iterations #{@iteration_count*100}"
    comm += " -style_image output/#{@style_image_name} -content_image output/#{@content_image_name} -output_image output/out.png"
    comm += " > output/output.log 2> output/error.log & \n"
    Resque.enqueue(WaitJob, @hostname, @username, @password, comm)
    sleep(10)
    Resque.remove_queue(:server1_wait_answer) ##AND KILL Buhahaha
  end


  def process_image3
    begin
      # Sent task for image
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        comm = "cd #{@remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
        comm += " && export LD_LIBRARY_PATH=/home/margo/torch/install/lib"
        comm += " && th neural_style.lua #{@init_params}"
        comm += " -style_image output/#{@style_image_name} -content_image output/#{@content_image_name}"# && ls \n "
        comm += " > output/output.log 2> output/error.log & && exit"
        @conn = ssh.exec!(comm)
        #ssh.shutdown!
        #ssh.wait(10)
        #ssh.open_channel do |c|
        #  c.exec(comm)
        #end

      end

    rescue
      return false
    end
    @conn
    #true
  end

  def download_data(filename)
    begin
      # Downloads files
      rem = "#{@remote_neural_path}/#{filename}"
      str = ""
      #loc =  "#{@local_tmp_path}/#{filename}"
      Net::SCP.download!(@hostname, @username,rem,loc,:password => @password )
    rescue
      return false
    end
    true
  end
end
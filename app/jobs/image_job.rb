require 'net/ssh'
require 'net/scp'
class ImageJob
  @STATUS_ERROR = -1
  @STATUS_NOT_PROCESSED = 0
  @STATUS_IN_PROCESS = 1
  @STATUS_PROCESSED = 2


  @queue = :server1
  #
  @hostname = "localhost"
  @username = "root"
  @password = "123"
  @remote_neural_path = "~/neural-style-master"
  @iteration_count

  @local_tmp_path = Rails.root.join('tmp/output')

  def set_config()
    file = Rails.root.join('config/config.secret')
    config = get_param_config(file, :workservers, :s1)
    @hostname = config["host"]
    @username = config["username"]
    @password = config["password"]
    @local_tmp_path = Rails.root.join('tmp/output')
    @remote_neural_path = config["remote_neural_path"]
    @iteration_count = 10
    @content_image = "jpg"
    @style_image = "jpg"

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

  def execute
    while true
      imgs = QueueImage.where("status = 0")
      if !imgs.nil? && imgs.count > 0 && !imgs.first(1)[0].nil?
        item = imgs.first(1)[0]
        res = execute_image(item)
        if !res.nil?
          if res == "OK"
            item.update({:status => 2})
          else
            item.update({:status => -1, :result => res})
          end
        end
      else
        #return "Zero"
      end
      sleep 5
      #wait_image
      #loc =  "#{@local_tmp_path}/out.png"
      #file = File.read(loc)
      #ImageMailer.send_image(1, 5, file).deliver_now
      #ImageMailer.send_image(1,5,file).deliver_now
    end
  end

  def execute_image(item)
    return nil if item.nil?
    #Change status to IN_PROCESS
    #item.status = @STATUS_PROCESSED
    item.update({:status => 1})
    # Check connection to workserver
    return "get_server_name: false" if get_server_name.nil?
    # Clear remote tmp folger
    return "rm_file_on_server: false" unless rm_file_on_server
    #Upload images to workserver
    @content_image = "input.#{item.content_image.to_s.split('.').last}"
    @style_image = "template.#{item.style_image.to_s.split('.').last}"
    return "upload_content_image: false" unless upload_image(item.content_image, "output/#{@content_image}")
    return "upload_stule_image: false" unless upload_image(item.style_image, "output/#{@style_image}")
    #Run process
    #return "process_image: false" unless
    process_image()

    return "wait_images: false" unless wait_images
    #Change status to PROCESSED
    #item.status = @STATUS_PROCESSED
    #item.save
    "OK"
  end

  protected

  def wait_images
    iter = 1
    sleep 5
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
    true
  end

  def save_image(iter_num)
    iter_num < @iteration_count ? name = "out_#{iter_num}00.png" : name = "out.png"
    download_image(name)
    loc =  "#{@local_tmp_path}/#{name}"
    file = File.read(loc)
    ImageMailer.send_image(iter_num, @iteration_count, file).deliver_now
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

  def download_image(filename)
    begin
      # Downloads files
      rem = "#{@remote_neural_path}/output/#{filename}"
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
      if File.exist?(loc)
        Net::SCP.upload!(@hostname, @username,loc.to_s,rem, :password => @password)
      else
        return false
      end

      #end
      #Net::SCP.start(@hostname, @username, :password => @password) do |scp|
        # upload a file to a remote server
       # rem = "#{@remote_neural_path}/#{remote_file_name}"
        #loc =  Rails.root.join("public#{loc_file_name}")
        #scp.upload! loc, rem
      #end

    rescue
      return false
    end
    true
  end


  def process_image2
    Resque.enqueue(WaitJob, @hostname, @username, @password, @remote_neural_path ,@iteration_count)
  end

  def process_image

    begin
      # Sent task for image
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        comm = "cd #{@remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
        comm += " && th neural_style.lua -gpu -1 -image_size 500 -num_iterations #{@iteration_count*100}"
        comm += " -style_image output/#{@style_image} -content_image output/#{@content_image} -output_image output/out.png"
        comm += " > output/output.log 2> output/error.log & \n"
        ssh.exec!(comm)
        #ssh.shutdown!
        #ssh.wait(10)
        #ssh.open_channel do |c|
         #  c.exec(comm)
        #end

      end
    rescue
      return false
    end
    true
  end




end
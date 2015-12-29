require 'net/ssh'
require 'net/scp'
class ImageJob
  include DebHelper
  include ConstHelper
  #@queue = :error_server
  #
  @hostname = "localhost"
  @username = "root"
  @password = "123"
  @remote_neural_path = "~/neural-style"
  @iteration_count = 10
  @local_tmp_path = '~/tmp/output'
  @worker_name = :server1
  @square_format = false

  def initialize(worker_name)
    @worker_name = worker_name
    #set_config(worker_name)
  end

  def set_config(worker_name)
    return if worker_name.nil?
    #@worker_name = worker_name.to_s
    file = Rails.root.join('config/config.secret')
    config = get_param_config(file, :workservers, worker_name.to_sym)
    return if config.blank?
    #@queue = worker_name.to_sym
    @hostname = config["host"]
    @username = config["username"]
    @password = config["password"]
    @local_tmp_path = Rails.root.join("tmp/#{worker_name}")
    if !Dir.exist?(@local_tmp_path)
      Dir.mkdir(@local_tmp_path)
    end
    @remote_neural_path = config["remote_neural_path"]
    @iteration_count = config["iteration_count"]
    @init_params = config["init_params"] + " -num_iterations #{@iteration_count*100}" #  -output_image output/"
    @content_image_name = "content.jpg"
    @style_image_name = "style.jpg"
    @admin_email = config["admin_email"]
    @square_format = config["square_format"]
    ##debug
    config["password"] = "*"
    log "config: #{config.to_s}"
  end

  def set_init_str(item)
    init = item.style.init
    if !item.init_str.blank?
      init = item.init_str
    end
    return true if init.blank?
    init = merge_init_params(@init_params, init)
    if init.nil?
      log "Merge init error: init_params[#{@init_params}] init[#{init}]"
      return false
    end
    @init_params = init
    log "init: #{init}"
    arr = init.split(' -')
    arr.each do |a|
      if a.scan('num_iterations').size > 0
        ar = a.split(' ')
        return false if ar.size < 2
         @iteration_count = (ar[1].to_i / 100).to_i
         log "iteration_count: #{@iteration_count}"
        return true
      end
    end
    false
  end

  def merge_init_params(init, par)
    init_hash = str_to_hash(' ' + init)
    par_hash = str_to_hash(' ' + par)
    return nil if init_hash.nil? || par_hash.nil?
    par_hash.each do |k,v|
      init_hash[k] = v
    end
    res = ''
    init_hash.each do |k,v|
      res << " -#{k} #{v}"
    end
    res
  end

  def str_to_hash(str)
    res = {}
    arr = str.split(' -')
    arr.each do |a|
      ar = a.split(' ')
      if ar.count == 2
        res[ar[0]] = ar[1]
      elsif ar.count == 1
        res[ar[0]] = ''
      end
    end
    res
  end

  def execute
    log "-----------------------Start Demon: #{@worker_name}---------------------"
    while true
      item = get_images_from_queue  # QueueImage.where("status = #{STATUS_NOT_PROCESSED}").order('created_at ASC')
      if !item.nil? #&& imgs.count > 0 && !imgs.first.nil?
        log("Images: #{item.attributes}")
        set_config(@worker_name)
        #item = imgs.first
        res = execute_image(item)
      else
        log "-----------------------Stop Demon---------------------------"
        return "Zero"
      end
      sleep 5
    end
  end

  def get_images_from_queue
    cl = Client.find_by_sql("select * from clients c where lastprocess is null and exists (select * from queue_images q where c.id = q.client_id and status = 1) order by created_at ASC")
    if cl.count == 0
      cl = Client.find_by_sql("select * from clients c where exists (select * from queue_images q where c.id = q.client_id and status = #{STATUS_NOT_PROCESSED}) order by lastprocess ASC")
    end
    return nil if cl.count == 0
    cl = cl.first
    log("Client: #{cl.attributes}")
    cl.queue_images.where("status = 1").order('created_at ASC').first
  end


  def execute_debug
    #set_config(@worker_name)
    #is_luajit_poc_exist
    #return

    loop do

      imgs = get_images_from_queue #QueueImage.where("status = #{STATUS_NOT_PROCESSED}").order('created_at ASC')
      if !imgs.nil? && imgs.count > 0 && !imgs.first.nil?
        set_config(@worker_name)
        item = imgs.first

        #
        process_time = Time.now

        #Change status to IN_PROCESS
        #item.update({:stime => process_time})
        #i = 1
        #10.times do
        # i += 1
        #end
        download_n_save_result(10,item)
        #
        process_time = Time.at(Time.now - process_time)
        item.update({:status => STATUS_PROCESSED, :ftime => Time.now, :ptime => process_time})
      else
        log "-----------------------Stop Demon---------------------------"
        return "Zero"
      end
     # sleep 5
    end
  end

  protected

  def is_luajit_proc_exist
    begin
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        com = "ps axu | grep luajit"
        output = ssh.exec!(com)
        if output.scan("th neural_style.lua").size > 0
          return nil
        else
          return output
        end
      end

    rescue

    end
    "Command ps axu error"
  end



  def execute_image(item)
    return nil if item.nil?
    process_time = Time.now

    log "-----------------------"
    log "execute_image item.id = #{item.id}"
    #Change status to IN_PROCESS
    if !set_init_str(item)
      err = "Init string ERROR"
      item.update({:status => STATUS_ERROR, :result => err})
      log err
      return err
    end
    #
    item.update({:status => STATUS_IN_PROCESS, :stime => process_time, :init_str => @init_params})
    item.style.update(use_counter: item.style.use_counter+1)
    # Check connection to workserver
    log "item.update"
    return "get_server_name: false" if get_server_name.nil?
    log "get_server_name not nil"
    # Clear remote tmp folger
    return "rm_file_on_server: false" unless rm_file_on_server
    log "rm_file_on_server"
    #Upload images to workserver
    @content_image_name = "content.#{item.content.image.to_s.split('.').last}"
    @style_image_name = "style.#{item.style.image.to_s.split('.').last}"
    #log "4"
    if @square_format
      return "upload_content_image: false" unless upload_image(item.content.image.to_proc.url, "output/#{@content_image_name}")
    else
      return "upload_content_image: false" unless upload_image(item.content.image, "output/#{@content_image_name}")
    end
    return "upload_stule_image: false" unless upload_image(item.style.image, "output/#{@style_image_name}")
    log "upload_content_style_image"
    #Run process
    send_start_process_comm()
    log "send_start_process_comm"
    sleep 10
    #log "6"
    # Wait processed images
    errors = wait_images(item)
    #
    log "process time: #{Time.now - process_time}"
    process_time = Time.at(Time.now - process_time)
    #
    if errors.nil?
      item.update({:status => item.end_status, :ftime => Time.now, :ptime => process_time})
      "OK"
    else
      item.update({:status => STATUS_ERROR, :result => errors, :ftime => Time.now, :ptime => process_time})
      errors += check_neural_start
      ImageMailer.send_error(@admin_email,"",item,errors).deliver_now
      log "wait_images: #{errors}"
    end
    item.client.update({:lastprocess => Time.now})
    #Change status to PROCESSED
    #item.status = @STATUS_PROCESSED
    #item.save
  end


  def check_neural_start
    log "check_neural_start"
    begin
      errors = ""
      # Check a output log
      rem = "#{@remote_neural_path}/output/output.log"
      loc = "#{@local_tmp_path}/output.log"
      Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
      if File.exist?(loc)
        log_str = File.read(loc)
        if !log_str.nil?
          #return str if str.scan("conv5_4").size == 0
        end
      else
        errors = "NO OUTPUT.LOG!\n\n"
      end

      # Check error log
      rem = "#{@remote_neural_path}/output/error.log"
      loc = "#{@local_tmp_path}/error.log"
      Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
      if File.exist?(loc)
        err_str = File.read(loc)
        if !err_str.nil?
          errors += "ERROR_IN_FILE!\n\n" if err_str.scan("error").size > 0
        end
      end
    rescue
      errors +="ERROR during download error.log and output.log\n\n"
    end

    errors += "output.log:\n\n#{log_str}\n\nerror.log:\n\n#{err_str}\n"
  end

  def wait_images(item)
    # Check remote neural process start
    #res = is_luajit_proc_exist#check_neural_start
    #log "DEBUG check_neural_start fail: #{res}" unless res.nil?
    #return res unless res.nil?
    log "wait_images"
    #
    iter = 1
    while true
      begin
        break if iter > @iteration_count
        flag = false
        # Sent task for image
        rem = "#{@remote_neural_path}/output/output.log"
        loc = "#{@local_tmp_path}/output.log"
        Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
        if File.exist?(loc)
          str = File.read(loc)
          s = "Iteration #{iter}00"
          if !str.nil? && str.scan(s).size > 0
            sleep 2
            download_n_save_result(iter,item)
            item.update(progress: iter.to_d/@iteration_count*100)
            iter += 1
            next
          end
        end
      rescue

      end
      res = is_luajit_proc_exist
      return res unless res.nil?
      #
      sleep 2
    end
    nil
  end

  def download_n_save_result(iter_num,item)
    if iter_num < @iteration_count
      name = "out_#{iter_num}00.png"
      num = iter_num
    else
      name = "out.png"
      num = 0
    end
    download_image(name)
    loc =  "#{@local_tmp_path}/#{name}"
    save_image(num,item,loc)
    if iter_num == @iteration_count
      ImageMailer.send_image(item.client, iter_num, @iteration_count, File.read(loc)).deliver_now
    end
    #
    log "save_image: #{name}"
  end

  def save_image(iter_num,item,loc)
    pimg = Pimage.new
    pimg.queue_image_id = item.id
    pimg.iterate = iter_num
    File.open(loc) do |f|
      pimg.imageurl = f
    end
    pimg.save!
  end

  def get_server_name
    output = nil
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
        log("command: #{com}")
        scr << com
        Net::SCP.upload!(@hostname, @username, StringIO.new(scr), rem, :password => @password)
        return true
      rescue

      end
    end
    false
  end

  def send_start_process_comm
    log "send_start_process_comm"
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

  def log(msg)
    write_log(msg, @worker_name)
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
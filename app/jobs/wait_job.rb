require 'net/ssh'
require 'net/scp'
class WaitJob


  @queue = :server1_wait_answer
  #
  @hostname = "localhost"
  @username = "root"
  @password = "123"
  @remote_neural_path = "~/neural-style-master"
  @iteration_count

  @local_tmp_path = Rails.root.join('tmp/output')

  def set_config(config)
    #
    @hostname = config["host"]
    @username = config["username"]
    @password = config["password"]
    @local_tmp_path = Rails.root.join('tmp/output')
    @remote_neural_path = "/home/margo/neural-style-master"#config["remote_neural_path"]
    @iteration_count = 1

  end


  def self.perform(*arg)
    hostname = arg[0]
    username = arg[1]
    password = arg[2]
    remote_neural_path = arg[3]
    iteration_count = arg[4]
    content_image = arg[5]
    style_image = arg[6]

    begin
      # Sent task for image

      Net::SSH.start(hostname, username, :password => password) do |ssh|
        comm = "cd #{remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
        comm += " && th neural_style.lua -gpu -1 -image_size 50 -num_iterations #{iteration_count*100}"
        comm += " -style_image output/#{style_image} -content_image output/#{content_image} -output_image output/out.png"
        comm += " > output/output.log 2> output/error.log &"
        ssh.exec!(comm)
        #ssh.shutdown!
      end
    rescue

    end
    true
  end

  def execute
    imgs = QueueImage.all()
    return "images zero" if imgs.nil? || imgs.count == 0
    item = imgs.first(1)[0]
    execute_image(item)
    #wait_image


  end

  def execute_image(item)
    return "image zero" if item.nil?
    #Change status to IN_PROCESS
    #item.status = @STATUS_IN_PROCESS
    #item.save
    # Check connection to workserver
    return "get_server_name: false" if get_server_name.nil?
    # Clear remote tmp folger
    return "rm_file_on_server: false" unless rm_file_on_server
    #Upload images to workserver
    return "upload_content_image: false" unless upload_image(item.content_image, "output/input.png")
    return "upload_stule_image: false" unless upload_image(item.style_image, "output/template.png")
    #Run process
    #return "process_image: false" unless
        process_image

    #Download result
    #return "process_image: false" unless download_image("out.png")

    return "wait_image: false" unless wait_image
    #Change status to PROCESSED
    #item.status = @STATUS_PROCESSED
    #item.save
    "OK"
  end

  protected

  def wait_image
    iter = 1
    while true
      begin
        # Sent task for image
        rem = "#{@remote_neural_path}/output/output.log"
        loc = "#{@local_tmp_path}/output.log"
        Net::SCP.download!(@hostname, @username, rem, loc , :password => @password )
        str = File.read(loc)
        s = "Iteration #{iter}00"
        if !str.nil? && str.scan(s).size > 0
          save_image(iter)
          iter += 1
        end
      rescue

      end
      break if iter > @iteration_count
      #wait 1000
    end
    true
  end

  def save_image(iter_num)
    if iter_num < @iteration_count ? name = "out_#{iter_num}00.png" : name = "out.png"
    end
    download_image(name)
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

  def process_image
    begin
      # Sent task for image
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        comm = "cd #{@remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
        comm += " && th neural_style.lua -gpu -1 -image_size 50 -num_iterations #{@iteration_count*100}"
        comm += " -style_image output/template.jpg -content_image output/input.jpg-output_image output/out.png"
        comm += " > output/output.log 2> output/error.log &"
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
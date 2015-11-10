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

  @local_tmp_path = Rails.root.join('tmp/output')

  def set_config(config)
    #
    @hostname = config["host"]
    @username = config["username"]
    @password = config["password"]
    @local_tmp_path = Rails.root.join('tmp/output')
    @remote_neural_path = "/home/margo/neural-style-master"#config["remote_neural_path"]

  end


  #def self.perform(num)
    # здесь делаем важные и полезные вещи
    # sent mail
       # puts "Job is done"
  #end

  def execute
    imgs = QueueImage.all()
    return "images zero" if imgs.nil? || imgs.count == 0
    img = imgs.first(1)[0]
    return "image zero" if img.nil?
    #Change status to IN_PROCESS
    #img.status = @STATUS_IN_PROCESS
    #img.save
    # Check connection to workserver
    return "get_server_name: false" if get_server_name.nil?
    # Clear remote tmp folger
    return "rm_file_on_server: false" unless rm_file_on_server
    #Upload images to workserver
    return "upload_content_image: false" unless upload_image(img.content_image, "output/input.png")
    return "upload_stule_image: false" unless upload_image(img.style_image, "output/template.png")
    #Run process
    return "process_image: false" unless process_image

      #&& rm_file_on_server
      #%w"rm -rf #{@local_tmp_path}"
      #upload_image("","output/input.jpg")
      #upload_image("","output/template.jpg")

    "OK"
  end

  protected

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
      rem = "#{@remote_neural_path}/input/#{filename}"
      loc =  "#{@local_tmp_path}/#{filename}"
      Net::SCP.download!(@hostname, @username,rem,loc,:ssh => { :password => @password })
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
        ssh.open_channel do |c|
          comm = "cd #{@remote_neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
          comm += " && th neural_style.lua -gpu -1 -image_size 50 -num_iterations 100"
          comm += " -style_image input/template.jpg -content_image input/input.jpg -output_image output/ou#{num}t.png"
          comm += " > output/output.log 2> output/error.log &"
          c.exec(comm)
        end

      end
    rescue
      return false
    end
    true
  end




end
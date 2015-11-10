require 'net/ssh'
require 'net/scp'
class ImageJob
  @queue = :server1
  #
  @hostname = "192.168.1.100"
  @username = "margo"
  @neural_path = "/home/margo/neural-style-master"
  @password = ""

  def self.perform(num)
    # здесь делаем важные и полезные вещи
    # sent mail
       # puts "Job is done"
  end

  def execute
    get_server_name()
    #if get_server_name != nil
      #&& rm_file_on_server




     # return true
    #end
    #false
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
        output = ssh.exec!("rm -rf #{@neural_path}/output/*")
        return true
      end
    rescue
      return false
    end
    false
  end

  def download_image(filename)

  end

  def upload_image

  end

  def process_image
    begin
      # Sent task for image
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        output = ssh.exec!("hostname")
        unless output.nil?
          res = ssh.exec!("rm -rf #{@neural_path}/output/*")
          ssh.open_channel do |c|
            comm = "cd #{@neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
            comm += " && th neural_style.lua -gpu -1 -image_size 50 -num_iterations 100"
            comm += " -style_image input/template.jpg -content_image input/input.jpg -output_image output/ou#{num}t.png"
            comm += " > output/output.log 2> output/error.log &"
            c.exec(comm)
          end
        end
      end
    rescue
      return "Unable to connect to start process"
    end
    begin
      # Downloads files
      Net::SCP.download!(@hostname, @username,"#{@neural_path}/output/ou#{num}t.png", "/home/matthew/RubymineProjects/ostagram/tmp/output/ou#{num}t.png", :ssh => { :password => @password })
    rescue
      return "Unable to connect to download result"
    end
  end




end
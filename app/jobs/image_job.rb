require 'net/ssh'
require 'net/scp'
class ImageJob
  @queue = :simple

  def self.perform
    # здесь делаем важные и полезные вещи
    @hostname = "192.168.1.100"
    @username = "margo"
    @neural_path = "/home/margo/neural-style-master"
    @password = "(ntvg123"

    begin
      # Sent task for image
      Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
        output = ssh.exec!("hostname")
        unless output.nil?
          res = ssh.exec!("rm -rf #{@neural_path}/output/*")
          ssh.open_channel do |c|
            comm = "cd #{@neural_path} && export PATH=$PATH:/home/margo/torch/install/bin"
            comm += " && th neural_style.lua -gpu -1 -image_size 50 -num_iterations 100"
            comm += " -style_image input/template.jpg -content_image input/input.jpg -output_image output/out.png"
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
      Net::SCP.download!(@hostname, @username,"#{@neural_path}/output/out.png", "/home/matthew/RubymineProjects/ostagram/tmp/output/out.png", :ssh => { :password => @password })
    rescue
      return "Unable to connect to download result"
    end
    # sent mail
       # puts "Job is done"
  end
end
require 'net/ssh'
require 'net/scp'

class ProcessImageJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
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
  end
end



#@comm = "asd"
#@comm = "#{@neural_path}/th neural_style.lua -gpu -1 -image_size 50 -style_image #{@neural_path}/input/template.jpg -content_image #{@neural_path}/input/input.jpg -output_image #{@neural_path}/output/out.png > #{@neural_path}/output/output.log &"
  # capture all stderr and stdout output from a remote process
  #@result = output.to_s
  #shell = session.shell.sync
  #shell.cd @neural_path
  #@result = shell.exec("ls")
  #comm = "cd #{@neural_path}; ls"
  #@result = ssh.exec!(comm)
  #@result += res.to_s
  #res = sh.exec!("ls")
  #@result += res.to_s
  #@result += res
  #comm = "asd"
  #@result = ssh.exec!(comm) {abort}

  #@result += res

#Net::SCP.start(@hostname, @username, :ssh => { :password => @password }) do |scp|
# upload a file to a remote server
# scp.download! "#{@neural_path}/output", "/home/matthew/RubymineProjects/ostagram/tmp/output"
#end



#ssh = Net::SSH.start(@hostname, @username, :password => @password)
#res = ssh.exec!("rm -rf #{@neural_path}/output/*")
#@result += res
#res = ssh.exec!("rm -rf output/*")
#@result += res
#command = "#{@neural_path}/th neural_style.lua -gpu -1 -image_size 50 -style_image input/template.jpg -content_image input/input.jpg -output_image output/out.png > output/output.log &"
#res = ssh.exec!(command)
#@result += res
#ssh.close
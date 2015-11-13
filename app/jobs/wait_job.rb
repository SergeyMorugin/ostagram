require 'net/ssh'
require 'net/scp'
class WaitJob


  @queue = :server1_wait_answer  #


  def self.perform(*arg)
    hostname = arg[0]
    username = arg[1]
    password = arg[2]
    command = arg[3]
    #iteration_count = arg[4]
    #content_image = arg[5]
    #style_image = arg[6]

    begin
      # Sent task for image

      Net::SSH.start(hostname, username, :password => password) do |ssh|
        ssh.exec!(command)
        #ssh.shutdown!
      end
    rescue

    end
    true
  end

end
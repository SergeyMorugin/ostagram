#require 'net/ssh'
#require 'net/scp'

class StaticPagesController < ApplicationController
  @@index = 0

  def home
  end

  def about
    #@@index += 1
    #Resque.enqueue(ImageJob, @@index)
        #ProcessImageJob.perform_later "asd"
    process_image
  end

  def error
  end

  protected

  def process_image
    file = Rails.root.join('config/config.secret')
    par = get_param_config(file, :workservers, :s1)
    Resque.enqueue(ResqueJob)

    #pri = ImageJob.new
    #pri.set_config
    #@result = pri.execute
    #pri.execute
     # @result = "OK"
    #else
    #  @result = "Error"
    #end

  end

end

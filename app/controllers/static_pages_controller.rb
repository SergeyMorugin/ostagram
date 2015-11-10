require 'net/ssh'
require 'net/scp'

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
    pri = ImageJob.new
    @result = pri.execute
    #if pri.execute
     # @result = "OK"
    #else
    #  @result = "Error"
    #end

  end

end

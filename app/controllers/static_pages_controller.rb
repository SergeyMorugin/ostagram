#require 'worker_helper'

class StaticPagesController < ApplicationController
  include WorkerHelper
  include DebHelper
  def home
    if client_signed_in?
      redirect_to lenta_path
      return
    else
      redirect_to about_path
      return
    end
  end


  def lenta
    @items= QueueImage.where("status > 9").order('ftime DESC').paginate(:page => params[:page], :per_page => 6)
  end

  def about
    #img_job = ImageJob.new(:server1)
    #img_job.set_config()
    #img_job.execute_debug
    #start_workers
    #process_image
  end



  def error

  end

  def admin_page

  end

  protected

  def process_image
    write_log "Start"
    start_workers
    loc =  Rails.root.join("tmp/output/out.png")
    file = File.read(loc)

  end

end

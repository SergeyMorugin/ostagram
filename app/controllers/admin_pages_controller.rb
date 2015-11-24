class AdminPagesController < ApplicationController
  include WorkerHelper
  def main
  end

  def images
    @items= QueueImage.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
  end

  def users
  end

  def startbot
    start_bot
    redirect_to admin_pages_main_path
    return
  end

  def startprocess
    start_workers
    redirect_to admin_pages_main_path
    return
  end
end

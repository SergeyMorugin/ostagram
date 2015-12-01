class AdminPagesController < ApplicationController
  include WorkerHelper
  after_action :verify_authorized
  before_action :set_authorize

  def pundit_user
    current_client
  end

  def self.policy_class
    AdminPage
  end


  def main

  end

  def images
    st = params[:status]
    if !st.nil? && st.to_i
      @items= QueueImage.where(status: st.to_i).order('updated_at DESC').paginate(:page => params[:page], :per_page => 10)
    else
      @items= QueueImage.all.order('updated_at DESC').paginate(:page => params[:page], :per_page => 10)
    end
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

  def unregworkers
    Resque.workers.each {|w| w.unregister_worker}
    redirect_to admin_pages_main_path
    return
  end

  def update_queue_status
    @queue_image = QueueImage.find(params[:id])
    @queue_image.update(status: params[:status])
    respond_to do |format|
      format.html { redirect_to admin_pages_images_path }
      format.js
    end
  end

  def update_style_status
    @queue_image = QueueImage.find(params[:id])
    @style = @queue_image.style
    @style.update(status: params[:status])
    respond_to do |format|
      format.html { redirect_to admin_pages_images_path }
      format.js
    end
  end

  private
  def set_authorize
    authorize AdminPage
  end

end

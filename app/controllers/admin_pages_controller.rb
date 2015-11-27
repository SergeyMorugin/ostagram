class AdminPagesController < ApplicationController
  include WorkerHelper
  after_action :verify_authorized
  def pundit_user
    current_client
  end

  def self.policy_class
    AdminPage
  end


  def main
    authorize AdminPage
  end

  def images
    authorize AdminPage
    @items= QueueImage.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
  end

  def users
    authorize AdminPage
  end

  def startbot
    authorize AdminPage
    start_bot
    redirect_to admin_pages_main_path
    return
  end

  def startprocess
    authorize AdminPage
    start_workers
    redirect_to admin_pages_main_path
    return
  end

end

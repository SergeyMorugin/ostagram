class AdminPagesController < ApplicationController
  def main
  end

  def images
    @items= QueueImage.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
  end

  def users
  end
end

#require 'worker_helper'

class StaticPagesController < ApplicationController
  include WorkerHelper

  def home
  end

  def about
    process_image
  end

  def error

  end

  def admin_page

  end

  protected

  def process_image
    start_workers
  end

end

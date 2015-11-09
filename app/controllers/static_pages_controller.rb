require 'net/ssh'
require 'net/scp'

class StaticPagesController < ApplicationController


  def home
  end

  def about
    ProcessImageJob.perform_later "asd"
  end

  def error
  end
end

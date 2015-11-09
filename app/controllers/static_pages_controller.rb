class StaticPagesController < ApplicationController
  def home
  end

  def about
    command = "ifconfig"
    @result = %xcommand
  end

  def error
  end
end

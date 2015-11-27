class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #validates :name, presence: true, if: :devise_controller?

  def after_sign_in_path_for(resource)
    lenta_path
  end

  protected

  def configure_permitted_parameters
    #devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:email, :name, :password, :password_confirmation, :avatar)
    }
  end

  def user_not_authorized
    flash[:alert] = "Cool hacker, you don`t have permission for this action!."
    redirect_to error_path
  end

end

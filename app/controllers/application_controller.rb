class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
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

end

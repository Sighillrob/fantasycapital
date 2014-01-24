class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :restrict_to_splash_page, unless: :devise_controller?

  protected

  def render_json_errors(model)
    render json: {errors: model.errors}, status: :unprocessable_entity
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
  end

  def restrict_to_splash_page
    redirect_to splash_path unless user_signed_in?
  end
end

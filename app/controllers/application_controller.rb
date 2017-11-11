class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def company
    @company ||= Company.current
  end
  helper_method :company

  def user_not_authorized
    flash[:alert] = 'Du bist nicht berechtigt, diese Seite zu sehen.'
    redirect_to (request.referrer || root_path)
  end


end

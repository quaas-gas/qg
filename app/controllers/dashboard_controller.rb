class DashboardController < ApplicationController
  before_action :authenticate_user!, except: :show
  after_action :verify_authorized, except: :show

  def index
    authorize :dashboard
  end

  def show
    redirect_to  user_signed_in? ? dashboard_url : new_user_session_url
  end
end

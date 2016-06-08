class SearchController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :search
    @query = params[:q]
    @result = PgSearch.multisearch(@query).to_a.map(&:searchable)
    redirect_to @result.first if @result.count == 1
  end
end

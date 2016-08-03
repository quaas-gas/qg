class StatisticsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]

  def index
    authorize Statistic
    @statistics = Statistic.all
  end

  def show
    @statistic.calculate!
  end

  def new
    authorize Statistic
    @statistic = Statistic.new time_range: { relative: 'last_year' },
                               grouping: { x: 'time', y: 'customer_category' }
  end

  def edit
  end

  def create
    authorize Statistic
    @statistic = Statistic.new statistic_params

    if @statistic.save
      redirect_to @statistic, notice: t(:created, model: Statistic.model_name.human)
    else
      render :new
    end
  end

  def update
    if @statistic.update statistic_params
      redirect_to @statistic, notice: t(:updated, model: Statistic.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @statistic.destroy
    redirect_to statistics_url, notice: t(:destroyed, model: Statistic.model_name.human)
  end

  def preview
    authorize Statistic
    @statistic = Statistic.new statistic_params
    @statistic.calculate!
    render partial: 'table', layout: false, locals: { statistic: @statistic }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_statistic
    @statistic = Statistic.find params[:id]
    authorize @statistic
  end

  # Only allow a trusted parameter "white list" through.
  def statistic_params
    p = params.require(:statistic).permit(:name, :time_range_relative, :start_date, :end_date,
                                          :grouping_x, :grouping_y, :sums_of,
                                          regions: [], customer_categories: [], product_categories: [])
    p[:time_range] = {
      relative:   p.delete(:time_range_relative),
      start_date: p.delete(:start_date),
      end_date:   p.delete(:end_date),
    }

    p[:grouping] = {}
    p[:grouping][:x] = p.delete :grouping_x
    p[:grouping][:y] = p.delete :grouping_y

    p[:filter] = {}
    p[:filter][:regions]             = p.delete(:regions).reject(&:blank?)
    p[:filter][:customer_categories] = p.delete(:customer_categories).reject(&:blank?)
    p[:filter][:product_categories]  = p.delete(:product_categories).reject(&:blank?)
    p
  end
end

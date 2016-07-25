class StatisticsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]

  def index
    authorize Statistic
    @statistics = Statistic.all
  end

  def show
  end

  def new
    authorize Statistic
    @statistic = Statistic.new
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_statistic
    @statistic = Statistic.find params[:id]
    authorize @statistic
  end

  # Only allow a trusted parameter "white list" through.
  def statistic_params
    params.require(:statistic).permit(:name, :time_range, :grouping, :filter, :sums_of)
  end
end

class ReportsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  def index
    authorize Report
    @reports = Report.all
  end

  def show
    start_date = Date.new 2016, 3, 1 # 18.days.ago.to_date
    end_date   = Date.new 2016, 3, 31 # 10.days.ago.to_date
    @report.calculate! start_date, end_date
  end

  def new
    authorize Report
    @report = Report.new
  end

  def edit
  end

  def create
    authorize Report
    @report = Report.new report_params

    if @report.save
      redirect_to @report, notice: t(:created, model: Report.model_name.human)
    else
      render :new
    end
  end

  def update
    if @report.update report_params
      redirect_to @report, notice: t(:updated, model: Report.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @report.destroy
    redirect_to reports_url, notice: t(:destroyed, model: Report.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report
    @report = Report.find params[:id]
    authorize @report
  end

  # Only allow a trusted parameter "white list" through.
  def report_params
    params.require(:report).permit(:name, :product_categories, :products, :in_menu)
  end
end

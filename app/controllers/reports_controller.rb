class ReportsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  def index
    authorize Report
    @reports = Report.all
  end

  def show
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @end_date   = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    @report.calculate! @start_date, @end_date

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportPdf.new(@report)
        send_data pdf.render, filename: pdf.filename, type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def free
    authorize Report
    @report = DeliveryReport.new filter: { date: 1.month.ago..Date.current }
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
    p = params.require(:report).permit(:name, :product_group, :product_categories,
      :content_product_categories, :products, :in_menu)
    %i(products product_categories content_product_categories).each do |listing|
      p[listing] = p[listing].split("\n").map(&:chomp)
    end
    p
  end
end

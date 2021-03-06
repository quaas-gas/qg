class ReportsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  def index
    authorize Report
    @reports = Report.all
  end

  def show
    @report.start_date = get_date :start_date, Date.current.beginning_of_week
    @report.end_date   = get_date :end_date,   Date.current

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

  def edit; end

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
    allowed = [
      :name, :in_menu, :product_group, product_categories: [], content_product_categories: []
    ]
    params.require(:report).permit(allowed).tap do |p|
      p[:product_categories].reject!(&:blank?)
      p[:content_product_categories].reject!(&:blank?)
    end
  end

  def get_date(date, default)
    params[date] ? Date.parse(params[date]) : default
  end
end

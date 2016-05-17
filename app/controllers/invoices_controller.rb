class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  def index
    authorize Invoice
    @invoices = Invoice
      .where(customer: Customer.active)
      .order(date: :desc, number: :desc)
      .includes(:customer)
      .page(params[:page])
      .all
  end

  def show
  end

  def new
    authorize Invoice
    @invoice = Invoice.new
  end

  def edit
  end

  def create
    authorize Invoice
    @invoice = Invoice.new invoice_params

    if @invoice.save
      redirect_to @invoice, notice: t(:created, model: Invoice.model_name.human)
    else
      render :new
    end
  end

  def update
    if @invoice.update invoice_params
      redirect_to @invoice, notice: t(:updated, model: Invoice.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_url, notice: t(:destroyed, model: Invoice.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find params[:id]
    authorize @invoice
  end

  # Only allow a trusted parameter "white list" through.
  def invoice_params
    params.require(:invoice).permit(:customer_id, :number, :date, :tax, :pre_message, :post_message, :address, :printed)
  end
end

class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    authorize Invoice

    @filter = InvoicesFilter.new(params)
    @invoices = @filter.result.includes(:customer, :items).all
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        # if true
          render(
            pdf:    "#{Invoice.model_name.human}_#{@invoice.number.sub('/', '-')}.pdf",
            header: { html: { template: 'invoices/header' } },
            footer: { html: { template: 'invoices/footer' } }
          )
        # else
        #   pdf = InvoicePdf.new(@invoice)
        #   send_data pdf.render, filename: pdf.filename, type: 'application/pdf', disposition: 'inline'
        # end
      end
    end
  end

  def new
    authorize Invoice
    if params[:customer_id].present?
      customer = Customer.find params[:customer_id]
      @invoice = customer.generate_next_invoice params[:delivery_ids]
    else
      @open_deliveries = Delivery.pending
    end
  end

  def edit
  end

  def create
    authorize Invoice
    @invoice = Invoice.new invoice_params
    @invoice.delivery_ids = params[:delivery_ids]
    @invoice.build_items_from_deliveries

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
    @invoice = Invoice.includes(:items, :customer).find params[:id]
    authorize @invoice
  end

  # Only allow a trusted parameter "white list" through.
  def invoice_params
    params.require(:invoice).permit(:customer_id, :number, :date, :pre_message, :post_message, :address, :tax)
  end
end

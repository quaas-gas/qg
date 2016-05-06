class CustomersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    authorize Customer
    @filter = CustomersFilter.new(params)
    @customers = @filter.result.page(params[:page]).all
  end

  def show
  end

  def new
    authorize Customer
    @customer = Customer.new
  end

  def edit
  end

  def create
    authorize Customer
    @customer = Customer.new customer_params

    if @customer.save
      redirect_to @customer, notice: t(:created, model: Customer.model_name.human)
    else
      render :new
    end
  end

  def update
    if @customer.update customer_params
      redirect_to @customer, notice: t(:updated, model: Customer.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_url, notice: t(:destroyed, model: Customer.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find params[:id]
    authorize @customer
  end

  # Only allow a trusted parameter "white list" through.
  def customer_params
    params.require(:customer)
      .permit(:salut, :name, :name2, :own_customer, :street, :city, :zip, :phone, :mobile, :email,
              :gets_invoice, :region, :kind, :price_in_net, :has_stock, :invoice_address, :archived)
  end
end
class CustomersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    authorize Customer
    @filter = CustomersFilter.new(params)
    @customers = @filter.result

    respond_to do |format|
      format.html { @customers = @customers.page(params[:page]).all }
      format.pdf do
        pdf = CustomersPdf.new(@customers, @filter)
        send_data pdf.render, filename: pdf.filename, type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def show
    params[:months] ||= 3
  end

  def new
    authorize Customer
    @customer = Customer.new
  end

  def edit
    3.times { @customer.prices.build } if params[:part] == 'prices'
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

  def price
    customer = Customer.find params[:customer_id]
    authorize customer
    product_id = params[:product_id]
    product = Product.find product_id
    price = customer.prices.find_by(product_id: product_id)
    json_price = { name: product.name, price: 0 }
    json_price[:price] = price.price.to_s if price
    render json: json_price
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
      .permit(:salut, :name, :name2, :street, :city, :zip, :phone, :mobile, :email, :gets_invoice,
              :region, :category, :tax, :has_stock, :invoice_address, :archived, :initial_stock_date,
              :notes, prices_attributes: [:id, :product_id, :valid_from, :price, :discount, :active,
                                          :in_stock, :initial_stock_balance, :_destroy])
  end
end

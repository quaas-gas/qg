class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]

  def index
    authorize Delivery

    @filter = DeliveriesFilter.new(params)
    @deliveries = @filter.result.includes(:customer, :seller, delivery_items: :product).all
  end

  def show
  end

  def new
    authorize Delivery
    @delivery = Delivery.new
    if params[:customer_id].present?
      @customer = Customer.includes(prices: :product).find params[:customer_id]
      @delivery.customer = @customer
      @delivery.on_account = @customer.gets_invoice
      prepare_items
    end
  end

  def edit
    prepare_items
  end

  def create
    authorize Delivery
    @delivery = Delivery.new delivery_params

    if @delivery.save
      redirect_to @delivery, notice: t(:created, model: Delivery.model_name.human)
    else
      prepare_items
      render :new
    end
  end

  def update
    if @delivery.update delivery_params
      redirect_to @delivery, notice: t(:updated, model: Delivery.model_name.human)
    else
      prepare_items
      render :edit
    end
  end

  def destroy
    @delivery.destroy
    redirect_to deliveries_url, notice: t(:destroyed, model: Delivery.model_name.human)
  end

  private

  def prepare_items
    @delivery.customer.prices.where(active: true).each do |price|
      if !@delivery.new_record? && @delivery.delivery_items.where(product: price.product).exists?
        next
      end
      @delivery.delivery_items.build product: price.product, unit_price: price.price, name: price.product.name
    end
    @delivery.delivery_items.build
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_delivery
    @delivery = Delivery.find params[:id]
    authorize @delivery
  end

  # Only allow a trusted parameter "white list" through.
  def delivery_params
    params.require(:delivery)
      .permit(:number, :customer_id, :date, :seller_id, :description, :on_account,
              delivery_items_attributes: [:id, :product_id, :count, :count_back, :unit_price, :name])
  end
end

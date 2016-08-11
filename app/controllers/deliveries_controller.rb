class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]
  after_action :set_last_delivery, only: :create

  def index
    authorize Delivery

    respond_to do |format|
      format.html do
        params[:date] = params[:date] ? Date.parse(params[:date]) : Delivery.order(date: :desc).first.date
        @filter = DeliveriesFilter.new(params)
        @deliveries = @filter.result.includes(:customer, :seller, items: :product).all
      end
      format.json do
        @filter = DeliveriesFilter.new(params)
        @deliveries = @filter.result.includes(:customer, :seller).all
      end
    end

  end

  def show
    @other_with_same_number = Delivery.where(number: @delivery.number).where.not(id: @delivery.id)
  end

  def new
    authorize Delivery
    @delivery = Delivery.new
    pre_fill_from_last
    pre_fill_customer
    prepare_items
  end

  def edit
    prepare_items
  end

  def create
    authorize Delivery
    @delivery = Delivery.new delivery_params

    if @delivery.save
      url = save_and_next? ? new_delivery_url : @delivery
      redirect_to url, notice: t(:created, model: Delivery.model_name.human)
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
  # Use callbacks to share common setup or constraints between actions.
  def set_delivery
    @delivery = Delivery.find params[:id]
    authorize @delivery
  end

  # Only allow a trusted parameter "white list" through.
  def delivery_params
    params.require(:delivery)
      .permit(:number, :customer_id, :date, :seller_id, :description, :on_account, :tax,
              items_attributes: [:id, :product_id, :count, :count_back, :unit_price, :name])
  end

  def save_and_next?
    params[:commit] == t(:save_and_next)
  end

  def pre_fill_from_last
    return unless session[:last_delivery_id]
    last_delivery = Delivery.where(id: session[:last_delivery_id]).first
    return unless last_delivery
    @delivery.date      = last_delivery.date
    @delivery.number    = last_delivery.number.next
    @delivery.seller_id = last_delivery.seller_id
  end

  def pre_fill_customer
    return unless params[:customer_id].present?
    customer             = Customer.includes(prices: :product).find params[:customer_id]
    @delivery.customer   = customer
    @delivery.on_account = customer.gets_invoice
    @delivery.tax        = customer.tax
  end

  def prepare_items
    @delivery.customer.prices.where(active: true).each do |price|
      next if !@delivery.new_record? && @delivery.items.where(product: price.product).exists?
      @delivery.items.build product: price.product, unit_price: price.price, name: price.product.name
    end if @delivery.customer
    3.times { @delivery.items.build }
  end

  def set_last_delivery
    if save_and_next?
      session[:last_delivery_id] = @delivery.id
    else
      session.delete :last_delivery_id
    end
  end
end

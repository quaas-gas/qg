class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]

  def index
    authorize Delivery

    @filter = DeliveriesFilter.new(params)
    @deliveries = @filter.result.includes(:customer, :seller, :delivery_items).all
  end

  def show
  end

  def new
    authorize Delivery
    @delivery = Delivery.new
    3.times { @delivery.delivery_items.build }
  end

  def edit
    3.times { @delivery.delivery_items.build }
  end

  def create
    authorize Delivery
    @delivery = Delivery.new delivery_params

    if @delivery.save
      redirect_to @delivery, notice: t(:created, model: Delivery.model_name.human)
    else
      render :new
    end
  end

  def update
    if @delivery.update delivery_params
      redirect_to @delivery, notice: t(:updated, model: Delivery.model_name.human)
    else
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
      .permit(:number, :customer_id, :date, :seller_id, :description, :on_account,
              delivery_items_attributes: [:id, :product_id, :count, :count_back, :unit_price, :name])
  end
end

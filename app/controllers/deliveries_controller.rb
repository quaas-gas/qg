class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]

  def index
    authorize Delivery

    @filter = DeliveriesFilter.new(params)
    @deliveries = @filter.result.includes(:customer, :seller).all
  end

  def show
  end

  def new
    authorize Delivery
    @delivery = Delivery.new
  end

  def edit
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
    params.require(:delivery).permit(:number, :number_show, :customer_id, :date, :driver, :description, :invoice_number, :on_account, :discount_net, :discount)
  end
end

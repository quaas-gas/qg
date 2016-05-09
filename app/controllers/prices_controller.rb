class PricesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_price, only: [:show, :edit, :update, :destroy]

  def index
    authorize Price
    @prices = Price.includes(:customer, :bottle).page(params[:page]).all
  end

  def show
  end

  def new
    authorize Price
    @price = Price.new
  end

  def edit
  end

  def create
    authorize Price
    @price = Price.new price_params

    if @price.save
      redirect_to @price.customer, notice: t(:created, model: Price.model_name.human)
    else
      render :new
    end
  end

  def update
    if @price.update price_params
      redirect_to @price.customer, notice: t(:updated, model: Price.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @price.destroy
    redirect_to prices_url, notice: t(:destroyed, model: Price.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_price
    @price = Price.find params[:id]
    authorize @price
  end

  # Only allow a trusted parameter "white list" through.
  def price_params
    params.require(:price).permit(:customer_id, :bottle_id, :valid_from, :price, :discount)
  end
end

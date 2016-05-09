class BottlesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_bottle, only: [:show, :edit, :update, :destroy]

  def index
    authorize Bottle
    @bottles = Bottle.all
  end

  def show
  end

  def new
    authorize Bottle
    @bottle = Bottle.new
  end

  def edit
  end

  def create
    authorize Bottle
    @bottle = Bottle.new bottle_params

    if @bottle.save
      redirect_to @bottle, notice: t(:created, model: Bottle.model_name.human)
    else
      render :new
    end
  end

  def update
    if @bottle.update bottle_params
      redirect_to @bottle, notice: t(:updated, model: Bottle.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @bottle.destroy
    redirect_to bottles_url, notice: t(:destroyed, model: Bottle.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bottle
    @bottle = Bottle.find params[:id]
    authorize @bottle
  end

  # Only allow a trusted parameter "white list" through.
  def bottle_params
    params.require(:bottle).permit(:number, :gas, :size, :name, :content, :cert_price, :cert_price_net, :deposit_price, :deposit_price_net, :disposal_price, :disposal_price_net)
  end
end

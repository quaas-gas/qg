class SellersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_seller, only: [:edit, :update, :destroy]

  def index
    authorize Seller
    @sellers = Seller.order(:last_name, :first_name).all
  end

  def new
    authorize Seller
    @seller = Seller.new
  end

  def edit
  end

  def create
    authorize Seller
    @seller = Seller.new seller_params

    if @seller.save
      redirect_to sellers_url, notice: t(:created, model: Seller.model_name.human)
    else
      render :new
    end
  end

  def update
    if @seller.update seller_params
      redirect_to sellers_url, notice: t(:updated, model: Seller.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @seller.destroy
    redirect_to sellers_url, notice: t(:destroyed, model: Seller.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_seller
    @seller = Seller.find params[:id]
    authorize @seller
  end

  # Only allow a trusted parameter "white list" through.
  def seller_params
    params.require(:seller).permit(:short, :first_name, :last_name, :mobile)
  end
end

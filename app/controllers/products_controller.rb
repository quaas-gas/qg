class ProductsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    authorize Product
    @product_group = params[:group] || Setting.product_groups.first
    @products      = Product.where(group: @product_group).order(:category, :number)
  end

  def show
  end

  def new
    authorize Product
    @product = Product.new
  end

  def edit
  end

  def create
    authorize Product
    @product = Product.new product_params

    if @product.save
      redirect_to products_url, notice: t(:created, model: Product.model_name.human)
    else
      render :new
    end
  end

  def update
    if @product.update product_params
      redirect_to products_url, notice: t(:updated, model: Product.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: t(:destroyed, model: Product.model_name.human)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find params[:id]
    authorize @product
  end

  # Only allow a trusted parameter "white list" through.
  def product_params
    params.require(:product)
      .permit(:number, :size, :name, :content, :unit, :category, :in_stock, :group)
  end
end

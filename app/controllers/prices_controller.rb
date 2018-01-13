class PricesController < ApplicationController
  def index
    @customer = Customer.find(params[:customer_id])
    @prices   = @customer.prices
  end

  def edit
    @price = Price.find params[:id]
    @customer = @price.customer
  end
end

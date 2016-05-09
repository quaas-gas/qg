class Product < ActiveRecord::Base

  monetize :price_cents, with_model_currency: :price_currency

end

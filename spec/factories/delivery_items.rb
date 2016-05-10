FactoryGirl.define do
  factory :delivery_item do
    delivery nil
    product nil
    name "MyString"
    count 1
    count_back 1
    unit_price ""
  end
end

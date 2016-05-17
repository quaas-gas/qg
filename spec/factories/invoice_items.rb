FactoryGirl.define do
  factory :invoice_item do
    invoice nil
    position 1
    count 1
    name "MyString"
    unit_price ""
    others ""
  end
end

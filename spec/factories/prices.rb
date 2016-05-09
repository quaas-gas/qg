FactoryGirl.define do
  factory :price do
    customer nil
    product nil
    valid_from "2016-05-09"
    price ""
    discount ""
  end
end

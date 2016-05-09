FactoryGirl.define do
  factory :delivery do
    number "MyString"
    number_show "MyString"
    customer nil
    date "2016-05-08"
    driver "MyString"
    description "MyText"
    invoice_number "MyString"
    on_account false
    discount_net ""
    discount ""
  end
end

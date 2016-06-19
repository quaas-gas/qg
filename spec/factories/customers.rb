FactoryGirl.define do
  factory :customer do
    salut "MyString"
    name "MyString"
    name2 "MyString"
    street "MyString"
    city "MyString"
    zip "MyString"
    phone "MyString"
    email "MyString"
    gets_invoice false
    region "MyString"
    category "MyString"
    has_stock false
    invoice_address "MyText"
  end
end

FactoryGirl.define do
  factory :customer do
    salut "MyString"
    name "MyString"
    name2 "MyString"
    contractor 'Contractor1'
    street "MyString"
    city "MyString"
    zip "MyString"
    phone "MyString"
    email "MyString"
    gets_invoice false
    region "MyString"
    kind "MyString"
    price_in_net false
    has_stock false
    invoice_address "MyText"
  end
end

FactoryGirl.define do
  factory :invoice do
    customer nil
    number "MyString"
    date "2016-05-17"
    tax false
    pre_message "MyText"
    post_message "MyText"
    address "MyText"
    printed false
  end
end

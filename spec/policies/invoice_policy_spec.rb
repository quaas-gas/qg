require 'rails_helper'

RSpec.describe InvoicePolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions ".scope" do
  end

  permissions :show? do
  end

  permissions :create? do
  end

  permissions :update? do
  end

  permissions :destroy? do
  end
end

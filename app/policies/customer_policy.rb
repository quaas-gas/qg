class CustomerPolicy < ApplicationPolicy
  def price?
    admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

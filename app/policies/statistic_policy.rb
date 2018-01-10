class StatisticPolicy < ApplicationPolicy

  def preview?
    true
  end

  def overview?
    admin?
  end

  def customers?
    admin?
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end

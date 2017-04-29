class StatisticPolicy < ApplicationPolicy

  def preview?
    true
  end

  def overview?
    admin?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end

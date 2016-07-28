class StatisticPolicy < ApplicationPolicy

  def preview?
    true
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

class ReportPolicy < ApplicationPolicy

  def free?
    admin?
  end

  def stats?
    admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

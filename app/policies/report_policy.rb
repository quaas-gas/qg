class ReportPolicy < ApplicationPolicy

  def free?
    admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

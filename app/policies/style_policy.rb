class StylePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def mark?
    true
  end
end

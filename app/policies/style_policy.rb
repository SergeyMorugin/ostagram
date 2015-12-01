class StylePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def check?
    true
  end
end

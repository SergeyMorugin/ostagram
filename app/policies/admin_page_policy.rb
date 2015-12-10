class AdminPagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def main?
    !user.nil? && user.admin?
  end

  def images?
    !user.nil? && user.admin?
  end

  def users?
    !user.nil? && user.admin?
  end

  def startbot?
    !user.nil? && user.admin?
  end

  def startprocess?
    !user.nil? && user.admin?
  end

  def unregworkers?
    !user.nil? && user.admin?
  end

  def update_queue_status?
    !user.nil? && user.admin?
  end

  def update_style_status?
    !user.nil? && user.admin?
  end

  def update_content_status?
    !user.nil? && user.admin?
  end

  def delete_queue?
    !user.nil? && user.admin?
  end
end

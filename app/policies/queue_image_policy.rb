class QueueImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
       scope.where(status: ConstHelper::STATUS_PROCESSED)
    end
  end

  def index?
    !user.nil?
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show?
    false
  end

  # GET /queue_images/new
  def new?
    create?
  end

  # GET /queue_images/1/edit
  def edit?
    update?
  end

  # POST /queue_images
  # POST /queue_images.json
  def create?
    !user.nil?
  end

  # PATCH/PUT /queue_images/1
  # PATCH/PUT /queue_images/1.json
  def update?
    user.admin?
  end

  # DELETE /queue_images/1
  # DELETE /queue_images/1.json
  def destroy?
    user.admin? #&& record.status != ConstHelper::STATUS_IN_PROCESS
  end

  def visible?
    user.admin?
  end

  def hidden?
    visible?
  end

end

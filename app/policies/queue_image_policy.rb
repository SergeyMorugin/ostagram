class QueueImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
       scope.where("status > -10 and status < 20")
    end
  end

  def index?
    !user.nil?
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show?
    !user.nil? && user.admin?
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
    !user.nil? && user.admin?
  end

  # DELETE /queue_images/1
  # DELETE /queue_images/1.json
  def destroy?
    user.admin? || (user.user? && user.id == record.client_id && (record.status == ConstHelper::STATUS_NOT_PROCESSED || record.status == ConstHelper::STATUS_PROCESSED))#&& record.status != ConstHelper::STATUS_IN_PROCESS
  end

  def visible?
    (user.admin? && record.status == ConstHelper::STATUS_HIDDEN) || (user.user? && user.id == record.client_id && record.status == ConstHelper::STATUS_HIDDEN)
  end

  def hidden?
    (user.admin? && record.status != ConstHelper::STATUS_HIDDEN) || (user.user? && user.id == record.client_id && record.status == ConstHelper::STATUS_PROCESSED )
  end

  def like_image?
    !user.nil? && Like.where("client_id = #{user.id} and queue_id = #{record.id}").count == 0
  end

  def unlike_image?
    !user.nil? && Like.where("client_id = #{user.id} and queue_id = #{record.id}").count == 1
  end

  def process_params?
    !user.nil? && user.admin?
  end

end

class QueueImagesController < ApplicationController
  include WorkerHelper
  include ConstHelper
  before_action :set_queue_image, only: [:show, :edit, :update, :destroy, :visible, :hidden, :like_image, :unlike_image]
  after_action :verify_authorized

  def pundit_user
    current_client
  end

  # GET /queue_images
  # GET /queue_images.json
  def index
    #@items= current_client.queue_images.all.order('created_at DESC')
    #@items= policy_scope(current_client.queue_images).order('created_at DESC').paginate(:page => params[:page], :per_page => 6)
    authorize QueueImage
    @items = policy_scope(current_client.queue_images).order('created_at DESC').paginate(:page => params[:page], :per_page => 6)

    #@items= QueueImage.where("status > 9").order('ftime DESC').paginate(:page => params[:page], :per_page => 6)
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show
    authorize @queue_image
  end

  # GET /queue_images/new
  def new
    @queue_image = QueueImage.new
    case params[:view_style]
      when '0' then @view_style = VIEW_STYLE_LOAD_FILE
      when '1' then @view_style = VIEW_STYLE_FROM_LIST
      when '2' then @view_style = VIEW_STYLE_FROM_LENTA
      else  @view_style = VIEW_STYLE_FROM_LIST
    end
    authorize @queue_image
    respond_to do |format|
      format.html { render :new}
      format.js
    end
  end

  # GET /queue_images/1/edit
  def edit

  end

  # POST /queue_images
  # POST /queue_images.json
  def create
    authorize QueueImage
    unless valid_queue_image_params
      redirect_to new_queue_image_path
      return
    end
    save_status = create_queue
    respond_to do |format|
      if save_status
        start_workers()
        format.html { redirect_to queue_images_path, notice: 'Изображения успешно добавлены в очередь обработки.' }
        format.json { render :show, status: :created, location: @queue_image }
      else
        format.html { render :new }
        format.json { render json: @queue_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queue_images/1
  # PATCH/PUT /queue_images/1.json
  def update
    respond_to do |format|
      if @queue_image.update(queue_image_params)
        format.html { redirect_to @queue_image, notice: 'Queue image was successfully updated.' }
        format.json { render :show, status: :ok, location: @queue_image }
      else
        format.html { render :edit }
        format.json { render json: @queue_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queue_images/1
  # DELETE /queue_images/1.json
  def destroy
    @queue_image.update(status: STATUS_DELETED)
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Изображения удалены.' }
      format.json { head :no_content }
    end
  end

  def visible
    @queue_image.update(status: STATUS_PROCESSED)
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Изображения открыты.' }
      format.json { head :no_content }
    end
  end

  def hidden
    @queue_image.update(status: STATUS_HIDDEN)
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Изображения скрыты.' }
      format.json { head :no_content }
    end
  end

  def like_image
    Like.transaction do
      Like.create(queue_id: @queue_image.id, client_id: current_client.id)
      @queue_image.update(likes_count: @queue_image.likes_count+1)
    end
    respond_to do |format|
      format.html { redirect_to queue_images_url}
      format.js
    end
  end

  def unlike_image
    Like.transaction do
      Like.where("client_id = #{current_client.id} and queue_id = #{@queue_image.id}").destroy_all
      @queue_image.update(likes_count: @queue_image.likes_count-1)
    end
    respond_to do |format|
      format.html { redirect_to queue_images_url}
      format.js
    end
  end

  private

    def create_queue
      queue_params = queue_image_params()
      save_status = false
      QueueImage.transaction do
        ci = Content.new(image: queue_params[:content_image])
        save_status = ci.save
        if queue_params[:view_style].blank? || queue_params[:view_style] == VIEW_STYLE_LOAD_FILE.to_s
          si = Style.new(image: queue_params[:style_image], init: queue_params[:init])
          save_status &= si.save
        elsif queue_params[:view_style] == VIEW_STYLE_FROM_LIST.to_s
          si = Style.find(queue_params[:style_id])
        end
        @queue_image = current_client.queue_images.new()
        @queue_image.content_id = ci.id
        @queue_image.style_id = si.id
        @queue_image.status = STATUS_NOT_PROCESSED
        @queue_image.end_status = STATUS_PROCESSED
        if queue_params[:end_status].nil?
          @queue_image.end_status = STATUS_PROCESSED
        else
          @queue_image.end_status = queue_params[:end_status].to_i
        end
        save_status &= @queue_image.save
      end
      save_status
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_queue_image
      @queue_image = QueueImage.find(params[:id])
      authorize @queue_image
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def queue_image_params
      params.require(:queue_image).permit(:content_image, :view_style , :style_image, :style_id, :init_str, :status, :result, :init, :end_status)
    end

    def valid_queue_image_params
      par = params[:queue_image][:content_image]
      if par.nil?
        flash[:alert] = "Пожалуйста, добавьте изображение для обработки"
        return false
      end
      par = params[:queue_image][:view_style]
      if par.nil? || par == VIEW_STYLE_LOAD_FILE.to_s
        if params[:queue_image][:style_image].nil?
          flash[:alert] = "Пожалуйста, добавьте изображение фильтра"
          return false
        end
      elsif par == VIEW_STYLE_FROM_LIST.to_s
        if params[:queue_image][:style_id].nil?
          flash[:alert] = "Пожалуйста, выберите изображение фильтра"
          return false
        end
      end

      true
    end

end

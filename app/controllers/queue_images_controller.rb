class QueueImagesController < ApplicationController
  include WorkerHelper
  before_action :set_queue_image, only: [:show, :edit, :update, :destroy]

  # GET /queue_images
  # GET /queue_images.json
  def index
    @items= QueueImage.all.order('created_at DESC')
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show
  end

  # GET /queue_images/new
  def new
    @queue_image = QueueImage.new
  end

  # GET /queue_images/1/edit
  def edit

  end

  # POST /queue_images
  # POST /queue_images.json
  def create
    @queue_image = QueueImage.new(queue_image_params)

    respond_to do |format|
      if @queue_image.save
        start_workers()
        format.html { redirect_to queue_images_path, notice: 'Изображения успешно добавленено в очередь обработки.' }
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
    @queue_image.destroy
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Изображения удалены.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_queue_image
      @queue_image = QueueImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def queue_image_params
      params.require(:queue_image).permit(:user_id, :content_image, :style_image, :init_str, :status, :result)
    end
end

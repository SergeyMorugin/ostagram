class QueueImagesController < ApplicationController
  include WorkerHelper
  before_action :set_queue_image, only: [:show, :edit, :update, :destroy]

  # GET /queue_images
  # GET /queue_images.json
  def index
    if !client_signed_in?
      redirect_to error_path, alert: 'Невозможно совершить данную операцию.'
      return
    end
    #@items= current_client.queue_images.all.order('created_at DESC')
    @items= current_client.queue_images.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 6)

    #@items= QueueImage.where("status > 9").order('ftime DESC').paginate(:page => params[:page], :per_page => 6)
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show
    redirect_to error_path, alert: 'Невозможно совершить данную операцию.'
    return
  end

  # GET /queue_images/new
  def new
    @queue_image = QueueImage.new
  end

  # GET /queue_images/1/edit
  def edit
    redirect_to error_path, alert: 'Невозможно совершить данную операцию.'
    return
  end

  # POST /queue_images
  # POST /queue_images.json
  def create
    unless valid_queue_image_params
      redirect_to new_queue_image_path
      return
    end


    #
    #eml = params[:queue_image][:user_id]
    #usr = User.find_or_create_by(email: eml)
    @queue_image = current_client.queue_images.build(queue_image_params)
    @queue_image.status = 1
    respond_to do |format|
      if @queue_image.save
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
    redirect_to error_path, alert: 'Невозможно совершить данную операцию.'
    return
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
    if @queue_image.status == 2
      redirect_to error_path, alert: 'Невозможно совершить данную операцию.'
      return
    end
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
      params.require(:queue_image).permit(:content_image, :style_image) #, :init_str, :status, :result)
    end

    def valid_queue_image_params
      par = params[:queue_image][:content_image]
      if par.nil?
        flash[:alert] = "Пожалуйста, добавьте изображение для обработки"
        return false
      elsif params[:queue_image][:style_image].nil?
        flash[:alert] = "Пожалуйста, добавьте изображение шаблона"
        return false
      end
      true
    end

end

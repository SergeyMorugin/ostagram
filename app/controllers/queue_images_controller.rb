class QueueImagesController < ApplicationController
  include WorkerHelper
  include ConstHelper
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
    @queue_image.status = 0
    @queue_image.save
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Изображения удалены.' }
      format.json { head :no_content }
    end
  end

  private

    def create_queue
      queue_params = queue_image_params()
      save_status = false
      QueueImage.transaction do
        ci = Content.new(image: queue_params[:content_image])
        save_status = ci.save
        if queue_params[:from_file].blank? || queue_params[:from_file] == '1'
          si = Style.new(image: queue_params[:style_image])
          save_status &= si.save
        else
          si = Style.find(queue_params[:queue_image][:style_id])
        end
        @queue_image = current_client.queue_images.new()
        @queue_image.content_id = ci.id
        @queue_image.style_id = si.id
        @queue_image.status = STATUS_NOT_PROCESSED
        @queue_image.end_status = STATUS_PROCESSED
        save_status &= @queue_image.save
      end
      save_status
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_queue_image
      @queue_image = QueueImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def queue_image_params
      params.require(:queue_image).permit(:content_image, :from_file, :style_image, :style_id) #, :init_str, :status, :result)
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

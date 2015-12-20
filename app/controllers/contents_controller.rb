class ContentsController < ApplicationController
  before_action :set_content, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized
  before_action :set_authorize

  def pundit_user
    current_client
  end
  # GET /contents
  # GET /contents.json
  def index
    st = params[:status]
    if !st.nil? && st.to_i
      @contents = Content.where(status: st.to_i).order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    else
      @contents = Content.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    end
  end

  # GET /contents/1
  # GET /contents/1.json
  def show
  end

  # GET /contents/new
  def new
    @content = Content.new
  end

  # GET /contents/1/edit
  def edit
  end

  # POST /contents
  # POST /contents.json
  def create
    @content = Content.new(content_params)

    respond_to do |format|
      if @content.save
        format.html { redirect_to new_content_path, notice: 'content was successfully created.' }
        format.json { render :show, status: :created, location: @content }
      else
        format.html { render :new }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contents/1
  # PATCH/PUT /contents/1.json
  def update
    respond_to do |format|
      if @content.update(content_params)
        format.html { redirect_to @content, notice: 'content was successfully updated.' }
        format.json { render :show, status: :ok, location: @content }
      else
        format.html { render :edit }
        format.json { render json: @content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.json
  def destroy
    @content.destroy
    respond_to do |format|
      format.html { redirect_to contents_url, notice: 'content was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_authorize
      authorize Content
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_content
      @content = Content.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def content_params
      params.require(:content).permit(:image, :init, :status, :use_counter)
    end
end

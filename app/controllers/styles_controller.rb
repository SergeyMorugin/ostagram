class StylesController < ApplicationController
  before_action :set_style, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized
  before_action :set_authorize

  def pundit_user
    current_client
  end

  def mark
    @mark_stale_id = nil
    if !params[:id].blank?
      @mark_style_id = params[:id]
    end
    respond_to do |format|
      format.js
    end
  end

  # GET /styles
  # GET /styles.json
  def index
    st = params[:status]
    if !st.nil? && st.to_i
      @styles = Style.where(status: st.to_i).order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    else
      @styles = Style.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    end
  end

  # GET /styles/1
  # GET /styles/1.json
  def show
  end

  # GET /styles/new
  def new
    @style = Style.new
  end

  # GET /styles/1/edit
  def edit
  end

  # POST /styles
  # POST /styles.json
  def create
    @style = Style.new(style_params)

    respond_to do |format|
      if @style.save
        format.html { redirect_to new_style_path, notice: 'style was successfully created.' }
        format.json { render :show, status: :created, location: @style }
      else
        format.html { render :new }
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /styles/1
  # PATCH/PUT /styles/1.json
  def update
    respond_to do |format|
      if @style.update(style_params)
        format.html { redirect_to @style, notice: 'style was successfully updated.' }
        format.json { render :show, status: :ok, location: @style }
      else
        format.html { render :edit }
        format.json { render json: @style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /styles/1
  # DELETE /styles/1.json
  def destroy
    @style.destroy
    respond_to do |format|
      format.html { redirect_to styles_url, notice: 'style was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_authorize
      authorize Style
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_style
      @style = Style.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def style_params
      params.require(:style).permit(:image, :init, :status, :use_counter)
    end
end

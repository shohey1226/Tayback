class Api::BlockersController < ApiController
  before_action :set_api_blocker, only: [:show, :edit, :update, :destroy]

  # GET /api/blockers
  # GET /api/blockers.json
  def index
    @api_blockers = Blocker.all
  end

  # GET /api/blockers/1
  # GET /api/blockers/1.json
  def show
  end

  # GET /api/blockers/new
  def new
    @api_blocker = Api::Blocker.new
  end

  # GET /api/blockers/1/edit
  def edit
  end

  # POST /api/blockers
  # POST /api/blockers.json
  def create

    begin
      ActiveRecord::Base.transaction do
        @blocker = Blocker.create!(api_blocker_params)
        p @blocker
        @site = site.find_or_create_by!(api_site_params)
        p @site
        @site.increment!(:count)
        @blocker.increment!(:count)
        current_user.blockers << @api_blocker
        current_user.sites << @site
        BlockerUser.find_by(user: current_user, blocker: @blocker).update!()
      end
    rescue => e

    end

    @api_blocker = Blocker.new(api_blocker_params)
    @site = site.find_or_create_by(api_site_params)

    respond_to do |format|
      if @api_site.save && @api_blocker.save && @api_site.increment(:count) && @api_blocker.increment!(:count) && current_user.blockers << @api_blocker &&
        format.json { render :show, status: :created, location: @api_blocker }
      else
        format.json { render json: @api_blocker.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /api/blockers/1
  # PATCH/PUT /api/blockers/1.json
  def update
    respond_to do |format|
      if @api_blocker.update(api_blocker_params)
        format.html { redirect_to @api_blocker, notice: 'Blocker was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_blocker }
      else
        format.html { render :edit }
        format.json { render json: @api_blocker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/blockers/1
  # DELETE /api/blockers/1.json
  def destroy
    @api_blocker.destroy
    respond_to do |format|
      format.html { redirect_to api_blockers_url, notice: 'Blocker was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_blocker
      @api_blocker = Api::Blocker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_blocker_params
      params.require(:blocker).permit(:title, :rule, :created_by)
    end

    def api_site_params
      params.require(:site).permit(:url)
    end

end

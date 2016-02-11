class Api::UsersController < ApiController
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

  # POST /api/users
  # 1. Check blocker if there is id
  #   *) if exists, then increment the blocker count
  #   *) if not, create the one
  # 2. Check the blocker whether there is relation to the user,
  #   *) if exists, update used_at with the current datetime
  #   *) if not, create the relation
  # 3. Check url in DB
  #   *) if exists, increment the site count
  #   *) if not, create url and add the relation to the user
  def create

    blocker = nil
    begin
      ActiveRecord::Base.transaction do

        if blocker_params[:id].present?
          blocker = Blocker.find_by_id(blocker_params[:id])
          if blocker.present?
            blocker.increment!(:count)
          else
            blocker = Blocker.create!(title: blocker_params[:title], rule: blocker_params[:rule], count: 1, created_by: current_user.id)
          end
          my_blocker = current_user.blockers.find_by_id(blocker.id)
          if my_blocker.blank?
            current_user.blockers << blocker
          end
          BlockerUser.find_by(user: current_user, blocker: blocker).update!(used_at: Time.now)
        end

        if site_params[:url].present?
          site = Site.find_by_url(site_params[:url])
          if site.present?
            site.increment!(:count)
          else
            site = Site.create!(url: site_params[:url], count: 1)
          end
           my_site = current_user.sites.find_by_id(site.id)
           if my_site.blank?
             current_user.sites << site
           end
           SiteUser.find_by(user: current_user, site: site).update(accessed_at: Time.now)
           BlockerUser.find_by(user: current_user, blocker: blocker).update!(site: site) if blocker.present?
        end
      end

    rescue => e
      puts e.message
      render json: {
        error: "failed the action"
      }, status: 401
    end

    render json: {
      message: "completed successfully",
      data: blocker,
    }

    # @api_blocker = Blocker.new(api_blocker_params)
    # @site = site.find_or_create_by(api_site_params)
    #
    # respond_to do |format|
    #   if @api_site.save && @api_blocker.save && @api_site.increment(:count) && @api_blocker.increment!(:count) && current_user.blockers << @api_blocker &&
    #     format.json { render :show, status: :created, location: @api_blocker }
    #   else
    #     format.json { render json: @api_blocker.errors, status: :unprocessable_entity }
    #   end
    # end

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
    def blocker_params
      params.require(:blocker).permit(:id, :title, :rule, :created_by)
    end

    def site_params
      params.require(:site).permit(:url)
    end

end

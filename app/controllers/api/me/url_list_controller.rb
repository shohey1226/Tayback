class Api::Me::UrlListController < ApiController
  before_action :set_api_blocker, only: [:show, :edit, :update, :destroy]

  # GET /api/me/url_list
  def show
  end

  # POST /api/me/url_list
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
    site = nil
    begin
      ActiveRecord::Base.transaction do
        blocker = current_user.find_or_create_blocker(blocker_params)
        site = current_user.find_or_create_site(site_params)
        site.increment!(:count)
        current_user.make_blocker_site_relation(blocker, site)
      end
    rescue => e
      puts e.message
      render json: {
        error: "failed the action"
      }, status: 401
    end

    if blocker.nil?
      render json: {
        message: "blocker not found",
      }, status: 404
    elsif site.nil?
      render json: {
        message: "site not found",
      }, status: 404
    else
      
      render json: {
        message: "completed successfully",
        data: {
          id: blocker.id,
          title: blocker.title,
          rule: blocker.generate_rule(site.url),
          count: site.blocker_count(blocker.id),
          owner: blocker.user
        },
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_blocker
      @api_blocker = Api::Blocker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blocker_params
      params.require(:blocker).permit(:id, :title, :rule, :user_id)
    end

    def site_params
      params.require(:site).permit(:url)
    end

end

class Api::Me::SitesController < ApiController
  before_action :set_api_user_blocker, only: [:update ]

  # GET /api/me/blockers
  def index
    urls = current_user.get_urls()
    render json: {
      message: "getting URLs completed successfully",
      data: urls
    }
  end

end

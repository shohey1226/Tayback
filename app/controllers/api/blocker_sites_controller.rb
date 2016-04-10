class Api::BlockerSitesController < ApiController

  # PUT /api/blocker_sites
  # params[:url], params[:blocker_id]
  def update
    site = Site.find_or_create_by!(url: params[:url], locale: current_user.locale)
    blocker = Blocker.find(params[:blocker_id])
    begin
      ActiveRecord::Base.transaction do
        current_user.update_count_and_timestamp!(blocker, site)
      end
    rescue => e
      puts e.message
      render json: {
        error: "failed to update count and timestamp"
      }, status: 401
    end
    render json: {
      message: "Updated count and timestamp successfully",
      data: current_user.url_list
    }
  end

end

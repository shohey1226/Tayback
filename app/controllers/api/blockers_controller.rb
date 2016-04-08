class Api::BlockersController < ApiController
  before_action :set_api_user_blocker, only: [:update ]

  # GET /api/me/blockers
  def index
    blockers = current_user.get_blockers(params[:url])
    render json: {
      message: "getting Blockers completed successfully",
      data: blockers
    }
  end

  # Create a new blocker
  def create
    blocker = nil
    site = nil
    begin
      ActiveRecord::Base.transaction do
        blocker = Blocker.create!(title: blocker_params[:title], rule: blocker_params[:rule], user_id: current_user.id)
        site = Site.find_or_create_by!(url: site_params[:url], locale: current_user.locale)
        current_user.make_blocker_site_relation(blocker, site) # create relation to site and user
      end
    rescue => e
      puts e.message
      render json: {
        error: "failed to create blocker "
      }, status: 401
    end

    render json: {
      message: "completed successfully",
      data: {
        id: blocker.id,
        title: blocker.title,
        rule: blocker.rule,
        count: 0,
        owner: {
          id: current_user.id,
          username: current_user.username,
          locale: current_user.locale
        }
      },
    }

  end

  # PUT /api/me/blockers
  def update
    blocker = current_user.update_blocker(blocker_params)
    if blocker.present?
      render json: {
        message: "updating blocker completed successfully",
        data: {
          id: blocker.id,
          title: blocker.title,
          rule: blocker.rule,
          ## *only upadate required one and return it
          # count: site.blocker_count(blocker.id),
          # owner: {
          #   id: blocker.user.id,
          #   username: blocker.user.username,
          #   locale: blocker.user.locale
          # }
        }
      }
    else
      render json: {
        error: "Failed to update blocker(ID:#{blocker_params[:id]})",
      }, status: 404
    end
  end

  # DELETE /api/me/blockers
  def destroy
    if current_user.delete_blocker_relation(params[:id])
      render json: {
        message: "Deleting blocker(ID:#{params[:id]}) completed successfully",
      }
    else
      render json: {
        error: "Failed to delete blocker(ID:#{params[:id]})",
      }, status: 404
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_user_blocker
      @blocker = Blocker.find(blocker_params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blocker_params
      params.require(:blocker).permit(:id, :title, :rule, :user_id)
    end

    def site_params
      params.require(:site).permit(:url)
    end

end

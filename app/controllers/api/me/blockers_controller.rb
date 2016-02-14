class Api::Me::BlockersController < ApiController
  before_action :set_api_user_blocker, only: [:update ]

  # GET /api/me/blockers
  def index
    blockers = current_user.get_blockers(params[:url])
    render json: {
      message: "getting Blockers completed successfully",
      data: blockers
    }
  end

  # PUT /api/me/blockers
  def update
    blocker = current_user.update_blocker(blocker_params)
    if blocker.present?
      render json: {
        message: "updating blocker completed successfully",
        data: blocker
      }
    else
      render json: {
        error: "Failed to update blocker(ID:#{blocker_params[:id]})",
      }, status: 404
    end
  end

  # DELETE /api/me/blockers
  def destroy
    if current_user.delete_blocker_relation(blocker_params[:id])
      render json: {
        message: "Deleting blocker(ID:#{blocker_params[:id]}) completed successfully",
      }
    else
      render json: {
        error: "Failed to delete blocker(ID:#{blocker_params[:id]})",
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
      params.require(:blocker).permit(:id, :title, :rule, :created_by)
    end

end

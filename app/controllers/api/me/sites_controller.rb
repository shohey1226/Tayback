class Api::Me::SitesController < ApiController
  before_action :set_api_user_blocker, only: [:update ]

  # GET /api/me/sites
  def index
    urls = current_user.get_urls()
    render json: {
      message: "getting URLs completed successfully",
      data: urls
    }
  end

  # POST /api/me/sites
  # Create Site if it doesn't exist
  def create
    url = params[:url]
    url.sub(/(\/)+$/, '')
    if uri?(url)
      begin
        site = Site.find_or_create_by(url: url, locale: current_user.locale)
        SizeScraper.perform_async(site.id, current_user.locale)
      rescue ActiveRecord::RecordNotUnique
        render json: {
          error: "Failed to create site",
        }, status: 404
      end
      render json: {
        message: "successfully performed"
      }
    else
      render json: {
        error: "Invalid URL",
      }, status: 404
    end
  end

  private

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end

end

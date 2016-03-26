class Api::Me::SitesController < ApiController
  before_action :set_api_user_blocker, only: [:update ]

  # GET /api/me/sites
  # get default URLs
  def index
    urls = current_user.get_urls()  # get 50 URLs with user's locale
    render json: {
      message: "Get URLs successfully",
      data: urls
    }
  end

  # get image/script url and size from Redis server
  def show
    if params[:url].present?
      site = Site.find_by(url: params[:url], locale: current_user.locale)
      if site.present?
        contents = site.get_contents
        render json: {
          message: "Get the contents of  #{params[:url]} successfully",
          data: contents
        }
      else
        render json: {
          error: "#{prams[:url]} doesn't exist",
        }, status: 404
      end
    else
      render json: {
        error: "Require url",
      }, status: 401
    end

  end

  # POST /api/me/sites
  # Create Site if it doesn't exist
  def create
    url = params[:url]
    url.sub!(/(\/)+$/, '')
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

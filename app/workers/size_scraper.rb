class SizeScraper
  include Sidekiq::Worker
  sidekiq_options queue: :sidekiq
  def perform(site_id, locale)
    logger.info "Run scraping.."
    site = Site.find(site_id)
    site.scrape(locale)
  end
end

class SizeScraper
  include Sidekiq::Worker
  sidekiq_options queue: :sidekiq
  def perform(site_id)
    site = Site.find(site_id)
    site.scrape
  end
end

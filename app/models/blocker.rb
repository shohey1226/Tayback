class Blocker < ActiveRecord::Base
  belongs_to :user
  has_many :blocker_sites
  has_many :sites, through: :blocker_sites

  def owner
    self.user
  end

  # def generate_rule(url, locale)
  #   if self.static?
  #     self.rule
  #   else
  #     site_string = redis.hget(url, locale)
  #     rule = []
  #     if site_string.present?
  #       site = JSON.parse(site_string)
  #       if self.image?
  #         site["data"].each{|key, value|
  #           if key =~ /image/
  #             value.each{|u, size|
  #               if self.upper_limit < size
  #                 rule.push({
  #                   "action" => {
  #                     "type" => "block"
  #                   },
  #                   "trigger" => {
  #                     "url-filter" => u
  #                   }
  #                 })
  #               end
  #             }
  #           end
  #         }
  #       elsif self.file?
  #         site["data"].each{|key, value|
  #           if key =~ /script/
  #             value.each{|u, size|
  #               if self.upper_limit < size
  #                 rule.push({
  #                   "action" => {
  #                     "type" => "block"
  #                   },
  #                   "trigger" => {
  #                     "url-filter" => u
  #                   }
  #                 })
  #               end
  #             }
  #           end
  #         }
  #       end
  #     end
  #     if rule.size == 0
  #       nil
  #     else
  #       rule.to_json
  #     end
  #   end
  # end

  private
  # def redis
  #   @redis ||= Redis.new
  # end

end

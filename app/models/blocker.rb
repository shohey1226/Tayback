class Blocker < ActiveRecord::Base
  belongs_to :user

  enum rule_type: { static: 0, image: 1, file: 2 }

  def owner
    self.user
  end

  def generate_rule(url)
    if self.static?
      self.rule
    else
      site_string = redis.get(url)
      rule = []
      if site_string.present?
        site = JSON.parse(site_string)
        if self.image?
          site["data"].each{|key, value|
            if key =~ /image/
              value.each{|u, size|
                if self.upper_limit < size
                  rule.push({
                    "action" => {
                      "type" => "block"
                    },
                    "trigger" => {
                      "url-filter" => u
                    }
                  })
                end
              }
            end
          }
        elsif self.file?
          site["data"].each{|key, value|
            value.each{|u, size|
              if self.upper_limit < size
                rule.push({
                  "action" => {
                    "type" => "block"
                  },
                  "trigger" => {
                    "url-filter" => u
                  }
                })
              end
            }
          }
        end
      end
      rule.to_s
    end
  end

  private
  def redis
    @redis ||= Redis.new
  end

end

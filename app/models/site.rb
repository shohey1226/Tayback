class Site < ActiveRecord::Base
  has_many :blocker_users
  has_many :blockers, through: :blocker_users

  def blocker_count(blocker_id)
    self.blockers.where(id: blocker_id).count
  end

  def scrape(locale)
    puts "target: #{self.url}"
    data = redis.hget(url, locale)
    if data.nil?
      data = Hash.new { |h,k| h[k] = {} }

      agent = Mechanize.new do |a|
        a.user_agent_alias = "iPhone"
        a.request_headers = {
          'accept-language' => "#{locale}, en",
          'accept-encoding' => 'utf-8, us-ascii'
        }
      end

      page = agent.get(url)
      #agent.page.encoding = 'utf-8'
      sum = page.header["content-length"].to_i

      page.search("//script/@src").each{|script_src|
        begin
          script_header = agent.head(script_src.value)
          next if script_header["content-type"].blank? || script_header["content-length"].blank?
          content_length = script_header["content-length"].to_i
          content_type = script_header["content-type"]
          data[content_type][URI.parse(script_src.value).path] = content_length
          sum += content_length if content_type =~ /script/
        rescue Exception => e
          p e
        end
      }

      # data = { content-type => { url => length }}
      page.images.map(&:url).uniq.each{|img_url|
        begin
          puts img_url
          image_header = agent.head(img_url)
          next if image_header["content-type"].blank? || image_header["content-length"].blank?
          content_length = image_header["content-length"].to_i
          content_type = image_header["content-type"]
          data[content_type][Addressable::URI.parse(img_url).path] = content_length
          sum += content_length if content_type =~ /image/
        rescue Exception => e
          p e
        end
      }

      page.search("//link/@href").each{|style_href|
        begin
          style_header = agent.head(style_href.value)
          next if style_header["content-type"].blank? || style_header["content-length"].blank?
          content_length = style_header["content-length"].to_i
          content_type = style_header["content-type"]
          data[content_type][URI.parse(style_href.value).path] = content_length
          sum += content_length if content_type =~ /css/
        rescue Exception => e
          p e
        end
      }
      redis.hset(
        url,
        locale,
        {
          data: data,
          sum: sum
        }.to_json
      )
      #redis.expire(url, 60*60)
    end
  end

  private

  def redis
    @redis ||= Redis.new
  end

end

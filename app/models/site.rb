class Site < ActiveRecord::Base
  has_many :blocker_users
  has_many :blockers, through: :blocker_users

  def blocker_count(blocker_id)
    self.blockers.where(id: blocker_id).count
  end

  def scrape
    puts "target: #{self.url}"
    data = redis.get(url)
    if data.nil?
      data = Hash.new { |h,k| h[k] = {} }
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
      page.search("//img/@src").each{|img|
        begin
          image_header = agent.head(img.value)
          next if image_header["content-type"].blank? || image_header["content-length"].blank?
          content_length = image_header["content-length"].to_i
          content_type = image_header["content-type"]
          data[content_type][URI.parse(img.value).path] = content_length
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
      redis.set(
        url,
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

  def agent
   @agent ||= Mechanize.new do |a|
     a.user_agent_alias = "iPhone"
   end
  end

end

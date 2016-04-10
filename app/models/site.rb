class Site < ActiveRecord::Base
  has_many :blocker_users
  has_many :blockers, through: :blocker_users
  has_many :site_users
  has_many :users, through: :site_users

  def blocker_count(blocker_id)
    self.blockers.where(id: blocker_id).count
  end

  def get_contents
    contents =  JSON.parse(redis.hget(self.url, self.locale))
    data = {}
    data['scripts'] = []
    data['images'] = []
    if contents.present?
      contents["data"].each{|type, obj|
        if type =~ /javascript/
          obj.sort_by{|k, v| v }.reverse.each{|url, size|
            data['scripts'].push({
              url: url,
              size: size
            })
          }
        elsif type =~ /image/
          obj.sort_by{|k, v| v }.reverse.each{|url, size|
            data['images'].push({
              url: url,
              size: size
            })
          }
        elsif type == "css-class"
          data['css-class'] = obj
        end
      }
      data
    else
      {}
    end
  end

  def scrape
    puts "target: #{self.url}"
    #data = redis.hget(url, self.locale)

    data = Hash.new { |h,k| h[k] = {} }

    agent = Mechanize.new do |a|
      a.user_agent_alias = "iPhone"
      a.request_headers = {
        'accept-language' => "#{self.locale}, en",
        'accept-encoding' => 'utf-8, us-ascii'
      }
    end

    page = agent.get(url)

    # Update title
    self.update(title: page.title)

    #agent.page.encoding = 'utf-8'
    sum = page.header["content-length"].to_i

    page.search("//script/@src").each{|script_src|
      begin
        script_header = agent.head(script_src.value)
        next if script_header["content-type"].blank? || script_header["content-length"].blank?
        content_length = script_header["content-length"].to_i
        content_type = script_header["content-type"]
        data[content_type][script_src.value] = content_length
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
        data[content_type][img_url] = content_length
        sum += content_length if content_type =~ /image/
      rescue Exception => e
        p e
      end
    }

    # Obtain CSS classes for display-none
    page.search("//img/@src").each{|img|
      css_classes = []
      img.ancestors.each{|anc|
        classes = anc[:class].to_s.split(/\s+/)
        if classes.size > 0
          css_classes += classes
        end
      }
      data["css-class"][img.value] = css_classes.uniq.sort
    }

    doc = Nokogiri::HTML(page.content.toutf8)
    children = doc.css('*')
    css_classes = []
    children.each{|child|
      css_classes += child[:class].to_s.split(/\s+/)
    }
    data["css-class"]["all"] = css_classes.uniq.sort


    # Style is needed. Just block JS and Image for now
    # page.search("//link/@href").each{|style_href|
    #   begin
    #     style_header = agent.head(style_href.value)
    #     next if style_header["content-type"].blank? || style_header["content-length"].blank?
    #     content_length = style_header["content-length"].to_i
    #     content_type = style_header["content-type"]
    #     data[content_type][URI.parse(style_href.value).path] = content_length
    #     sum += content_length if content_type =~ /css/
    #   rescue Exception => e
    #     p e
    #   end
    # }

    redis.hdel(url, self.locale);
    redis.hset(
    url,
    self.locale,
    {
      data: data,
      sum: sum
    }.to_json
    )
    #redis.expire(url, 60*60)
  end

  private

  def redis
    @redis ||= Redis.new
  end

end

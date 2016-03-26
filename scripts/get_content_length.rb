require 'mechanize'
require 'nokogiri'

agent = Mechanize.new
agent.user_agent_alias = "iPhone"
#url = "http://m.yahoo.co.jp"
url = "https://global-step.jp"

page = agent.get(url)
agent.page.encoding = 'utf-8'

# doc = Nokogiri::HTML(page.content.toutf8)
# children = doc.css('*')
# # children.each do |child|
# #     puts child[:class]
# # end
# css_classes = []
# children.each{|child|
#   css_classes += child[:class].to_s.split(/\s+/)
# }
# css_classes.uniq!.sort!
# puts css_classes
#
# exit


# contet-length is byte
# 1kbps 125bytes/s
# 128kbps 125*128 = 16000
# 37051 bytpes / 125

scripts = {}
styles= {}
images = {}

# page.search("//script/@src").each{|script|
#   next if scripts[script.value] != nil
#   scripts[script.value] = agent.head(script.value)["content-length"]
# }

page.search("//img/@src").each{|img|
  next if images[img.value] != nil

  css_classes = []
  img.ancestors.each{|anc|
    css_classes.push(anc[:class].to_s.split(/\s+/))
  }
  css_classes.uniq!.sort!
  puts img.value
  puts css_classes

  begin
    img_head = agent.head img.value
    images[img.value] =  img_head["content-length"] unless img_head["content-length"] == nil
  rescue Exception => e
    p e
  end
}

# page.search("//link/@href").each{|style|
#   next if styles[style.value] != nil
#   styles[style.value] = agent.head(style.value)["content-length"]
# }

p scripts
p images
p styles

# agent.get(url) do |page|
#
#   html_doc = page.root
#
#   p html_doc
#   script = html_doc.at_xpath('//script/@src')
#   p script
#
#   # doc = Nokogiri::HTML(page.content.toutf8)
#   # doc.search("//img/@src").each{|img|
#   #   puts img.value
#   #   img_head = agent.head img.value
#   #   puts img_head["content-length"]
#   # }
#
# end

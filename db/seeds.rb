Blocker.create!([
  {title: "Block all images", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\"]}}]", count: 0, created_by: 1},
  {title: "Block third-party", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"load-type\":[\"third-party\"]}}]", count: 0, created_by: 1},
  {title: "Block all images and webfont", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\",\"font\"]}}]", count: 0, created_by: 1},
])
# Site.create!([
#   {url: "http://yahoo.co.jp", title: nil, locale: nil, count: 3}
# ])

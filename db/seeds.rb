Blocker.create!([
  {title: "Block all images", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\"]}}]", count: 0, created_by: nil},
  {title: "Block third-party", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"load-type\":[\"third-party\"]}}]", count: 0, created_by: nil},
  {title: "Block all images and webfont", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\",\"font\"]}}]", count: 0, created_by: nil},
])

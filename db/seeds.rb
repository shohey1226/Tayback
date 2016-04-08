Blocker.create!([
  {title: "No blocking", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\"TXUATjdOYILJLoJYwoDvPurVl0HfqMm1KYDREn8hkQbz6zC3yaU4WIfr4ijuxhK8\"}}]", user_id: nil},
  {title: "Block all images", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\"]}}]", user_id: nil},
  {title: "Block all images and fonts", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\",\"font\"]}}]", user_id: nil},
  {title: "Block all scripts", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"script\"]}}]", user_id: nil},
  {title: "Block all images, fonts and scripts", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\",\"font\",\"script\"]}}]", user_id: nil},
  {title: "Block all from third-party", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"load-type\":[\"third-party\"]}}]", user_id: nil},
  {title: "Block all from third-party and images", rule: "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"load-type\":\"third-party\"}},{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\",\"resource-type\":[\"image\"]}}]", user_id: nil},
])

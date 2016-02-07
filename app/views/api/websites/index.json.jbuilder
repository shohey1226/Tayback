json.array!(@api_websites) do |api_website|
  json.extract! api_website, :id
  json.url api_website_url(api_website, format: :json)
end

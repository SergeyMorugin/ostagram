json.array!(@contents) do |content|
  json.extract! content, :id, :image, :status
  json.url s1tyle_url(content, format: :json)
end

json.array!(@styles) do |style|
  json.extract! style, :id, :image, :init, :status, :use_counter
  json.url s1tyle_url(style, format: :json)
end

json.array!(@queue_images) do |queue_image|
  json.extract! queue_image, :id, :user_id, :content_image, :style_image, :init_str, :status, :result
  json.url queue_image_url(queue_image, format: :json)
end

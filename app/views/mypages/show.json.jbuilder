json.array! @posts do |post|
  json.id post.id
  json.user_id post.user_id
  json.user_uid post.user.uid
  json.created_at post.created_at.strftime('%Y年%m月%d日')
  
  json.post_images post.post_images do |post_image|
    json.id post_image.id
    json.url post_image.image.url(:thumb)
  end
  
  json.post_images_count post.post_images.count
end
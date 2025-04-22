# app/views/posts/index.json.jbuilder
json.posts @posts do |post|
  json.id post.id
  json.content post.content
  json.user_uid post.user.uid
  json.user_profile_image post.user.profile_image_url.present? ? post.user.profile_image_url.url : nil
  json.prefecture_name post.prefecture.name
  json.created_at l(post.created_at, format: :long)

  json.images post.post_images do |post_image|
    if post_image.image.present? && post_image.image.url.present?
      json.url post_image.image.url
    else
      json.url nil
    end
  end

  json.hashtags post.hashtags do |hashtag|
    json.name hashtag.name
  end
end

json.next_page @posts.next_page
json.total_pages @posts.total_pages
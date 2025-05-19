module PostsJsonBuildable
  extend ActiveSupport::Concern

  private

  def build_posts_json
    {
      posts: @posts.map { |post| build_post_json(post) },
      next_page: @posts.next_page.present?
    }
  end

  def build_post_json(post)
    {
      id: post.id,
      content: post.content,
      created_at: l(post.created_at, format: :long),
      user: {
        id: post.user.id,
        uid: post.user.uid,
        profile_image_url: post.user.profile_image_url&.url
      },
      prefecture: {
        id: post.prefecture.id,
        name: post.prefecture.name
      },
      hashtags: post.hashtags.map { |tag| { id: tag.id, name: tag.name } },
      post_images: post.post_images.map { |img| { id: img.id, image: { url: img.image&.url } } }
    }
  end
end

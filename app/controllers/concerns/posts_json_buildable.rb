# JSON応答の構築に関連する機能を提供するモジュール
module PostsJsonBuildable
  extend ActiveSupport::Concern

  private

  # 投稿データをJSON形式で構築するメソッド
  def build_posts_json
    {
      posts: @posts.map { |post| build_post_json(post) },
      next_page: @posts.next_page.present?
    }
  end

  # 単一の投稿をJSONに変換
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

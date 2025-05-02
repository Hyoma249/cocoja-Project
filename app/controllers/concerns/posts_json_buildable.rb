# JSON応答の構築に関連する機能を提供するモジュール
module PostsJsonBuildable
  extend ActiveSupport::Concern

  private

  # 投稿データをJSON形式で構築するメソッド
  def build_posts_json
    {
      posts: @posts.as_json(
        include: build_json_includes,
        methods: [:created_at_formatted]
      ),
      next_page: @posts.next_page.present?
    }
  end

  # JSON応答に含めるアソシエーションと属性を定義するメソッド
  def build_json_includes
    [
      { user: { only: [:uid], methods: [:profile_image_url] } },
      { prefecture: { only: [:name] } },
      { hashtags: { only: [:name] } },
      { post_images: { only: [], methods: [:image] } }
    ]
  end
end

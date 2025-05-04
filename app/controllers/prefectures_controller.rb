# 都道府県（Prefecture）に関する操作を担当するコントローラー
class PrefecturesController < ApplicationController
  def show
    @prefecture = Prefecture.find(params[:id])

    @posts = @prefecture.posts.joins(:votes)
                        .select('posts.*, SUM(votes.points) as total_points_sum')
                        .group('posts.id')
                        .having('SUM(votes.points) > 0')
                        .order('total_points_sum DESC')

    @posts_count = @posts.length
    @total_points = @prefecture.posts.joins(:votes).sum('votes.points')
  end

  # 都道府県に関連する投稿の一覧表示
  def posts
    # 都道府県を取得
    @prefecture = Prefecture.find(params[:id])

    # 都道府県に紐づく投稿を新しい順に取得
    @posts = @prefecture.posts
                       .includes(:user, :hashtags, :post_images)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(10)

    # 投稿総数の取得
    @posts_count = @prefecture.posts.count

    # タイトル設定
    @page_title = "#{@prefecture.name}の投稿"

    # レスポンス形式に応じた処理
    respond_to do |format|
      format.html do
        # HTML形式の場合、統計情報を取得
        @total_points = @prefecture.posts.left_joins(:votes).sum('COALESCE(votes.points, 0)')
      end

      # JSON形式のレスポンス（無限スクロール用）
      format.json do
        render json: {
          posts: @posts.as_json(
            include: [
              { user: { methods: :profile_image_url } },
              { post_images: { methods: [:image] } },
              :hashtags, 
              :prefecture
            ],
            methods: :created_at_formatted
          ),
          next_page: @posts.next_page
        }
      end
    end
  end
end

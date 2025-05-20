class PrefecturesController < ApplicationController
  def show
    @prefecture = Prefecture.find(params[:id])

    @posts = @prefecture.popular_posts

    @posts_count = @posts.length
    @total_points = @prefecture.total_votes_points
  end

  def posts
    @prefecture = Prefecture.find(params[:id])
    @posts = @prefecture.posts.with_associations.recent
                        .page(params[:page]).per(10)

    @posts_count = @prefecture.posts.count

    @page_title = "#{@prefecture.name}の投稿"

    respond_to do |format|
      format.html do
        @total_points = @prefecture.total_votes_points
      end

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

class PostsController < ApplicationController
  before_action :authenticate_user!
  include PostsHelper
  include PostsJsonBuildable
  include PostCreatable

  POSTS_PER_PAGE = 12

  def index
    @user = current_user
    load_posts_with_filters

    respond_to do |format|
      format.html
      format.json do
        page = (params[:page] || 1).to_i
        @posts = Post.with_associations.recent.paginate(page, POSTS_PER_PAGE)

        render json: build_posts_json
      end
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
    @prefectures = Prefecture.all
    @post.post_images.build
  end

  def create
    @post = current_user.posts.build(post_params)

    return handle_max_images_exceeded if max_images_exceeded?

    save_post_with_images
  end

  def hashtag
    @user = current_user
    @tag = Hashtag.find_by(name: params[:name])

    if @tag
      load_hashtag_posts
      render_response
    else
      redirect_to posts_url(protocol: 'https'), notice: t('controllers.posts.hashtag.not_found')
    end
  end

  private

  def post_params
    params.require(:post).permit(:prefecture_id, :content, post_images_attributes: [:image])
  end

  def load_posts_with_filters
    @posts = Post.with_associations.recent
    @posts = @posts.by_hashtag(params[:name]) if params[:name].present?
    @posts = @posts.paginate((params[:page] || 1).to_i, POSTS_PER_PAGE)
  end

  def load_hashtag_posts
    @posts = @tag.posts.distinct.with_associations.recent
                 .paginate((params[:page] || 1).to_i, POSTS_PER_PAGE)
  end

  def render_response
    respond_to do |format|
      format.html
      format.json { render json: build_posts_json }
    end
  end
end

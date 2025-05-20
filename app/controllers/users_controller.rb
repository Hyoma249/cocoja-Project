class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show following followers posts]

  def show
    @posts = @user.posts.with_associations.recent
  end

  def following
    @title = t('controllers.users.following.title')
    @users = @user.followings.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = t('controllers.users.followers.title')
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  def posts
    @posts = @user.posts.with_associations.recent

    respond_to do |format|
      format.html
      format.json {
        page = (params[:page] || 1).to_i
        per_page = 12

        paginated_posts = @posts.paginate(page, per_page)
        render json: {
          posts: render_to_string(partial: 'posts/post', collection: paginated_posts, formats: [:html]),
          next_page: page + 1,
          last_page: paginated_posts.size < per_page
        }
      }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('controllers.users.not_found')
    redirect_to root_path
  end
end

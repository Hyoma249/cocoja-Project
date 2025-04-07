class MypagesController < ApplicationController
  def index
    @user = current_user
    @posts = current_user.posts.includes(:post_images).order(created_at: :desc)
  end
end

class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    current_user.follow(@user) unless current_user.following?(@user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: 'フォローしました' }
    end
  end

  def destroy
    current_user.unfollow(@user) if current_user.following?(@user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: 'フォローを解除しました' }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

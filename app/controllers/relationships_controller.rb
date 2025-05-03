# フォロー関係（Relationship）に関する操作を担当するコントローラー
# ユーザー間のフォロー・アンフォロー機能を提供します
class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      format.turbo_stream { render turbo_stream: turbo_stream.replace('follow_form', partial: 'users/follow_form') }
    end
  end

  def destroy
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      format.turbo_stream { render turbo_stream: turbo_stream.replace('follow_form', partial: 'users/follow_form') }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

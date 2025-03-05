# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # メール確認後の処理をオーバーライド
  def after_confirmation_path_for(resource_name, resource)
    # ユーザーのプロフィールが存在するか確認
    if resource.profile.nil?
      # sign_inメソッドで自動ログイン
      sign_in(resource)
      # プロフィール新規作成ページへリダイレクト
      new_profile_path
    else
      # 既にプロフィールがある場合は通常のログインページへ
      new_user_session_path
    end
  end
end

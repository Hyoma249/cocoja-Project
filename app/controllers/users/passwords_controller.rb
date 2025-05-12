# frozen_string_literal: true# パスワード管理に関する操作を担当するコントローラー
# パスワードのリセット機能を提供します
module Users
  class PasswordsController < Devise::PasswordsController
    # POST /resource/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        # フラッシュメッセージを設定
        flash[:notice] = I18n.t('devise.passwords.send_instructions')

        # 明示的にサインインページへリダイレクト
        redirect_to new_user_session_path
      else
        respond_with(resource)
      end
    end
  end
end

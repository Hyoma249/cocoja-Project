# frozen_string_literal: true
# パスワード管理に関する操作を担当するコントローラー
# パスワードのリセット機能を提供します
module Users
  class PasswordsController < Devise::PasswordsController
    # POST /resource/password
    def create
      Rails.logger.debug("パスワードリセット処理を開始します")
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        Rails.logger.debug("パスワードリセットメール送信成功: #{resource.email}")

        # 重要: responsd_withを使わず、明示的にリダイレクト
        flash[:notice] = I18n.t('devise.passwords.send_instructions')
        return redirect_to new_user_session_path
      else
        Rails.logger.debug("パスワードリセットメール送信失敗: #{resource.errors.full_messages}")
        respond_with(resource)
      end
    end
  end
end

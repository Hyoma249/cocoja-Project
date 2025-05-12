# frozen_string_literal: true# パスワード管理に関する操作を担当するコントローラー
# パスワードのリセット機能を提供します
module Users
  class PasswordsController < Devise::PasswordsController
    # POST /resource/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        set_flash_message! :notice, :send_instructions
        # Turbo対応のためのリダイレクト
        if request.format == :turbo_stream
          redirect_to after_sending_reset_password_instructions_path_for(resource_name), notice: I18n.t('devise.passwords.send_instructions')
        else
          respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
        end
      else
        respond_with(resource)
      end
    end
  end
end

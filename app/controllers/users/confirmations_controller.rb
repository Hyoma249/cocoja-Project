# メール確認に関する操作を担当するコントローラー
# アカウント認証機能を提供します
module Users
  class ConfirmationsController < Devise::ConfirmationsController
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

    # メールアドレス確認後のリダイレクト先
    def after_confirmation_path_for(resource_name, resource)
      sign_in(resource)
      # プロフィール設定ページへリダイレクト
      profile_setup_path
    end
  end
end

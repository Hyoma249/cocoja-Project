# ユーザー登録に関する操作を担当するコントローラー
# アカウント作成と管理機能を提供します
module Users
  # Deviseの登録コントローラーを拡張し、カスタム登録フローを提供します
  class RegistrationsController < Devise::RegistrationsController
    # POST /resource
    def create
      super do |resource|
        if resource.persisted?
          sign_in(resource)
          # プロフィール設定ページへリダイレクト
          redirect_to profile_setup_path and return
        end
      end
    end

    protected

    # 基本情報登録（メールアドレスとパスワード）後のリダイレクト先を変更
    def after_sign_up_path_for(_)
      profile_setup_path
    end
  end
end

# ユーザー登録に関する操作を担当するコントローラー
# アカウント作成と管理機能を提供します
module Users
  # Deviseの登録コントローラーを拡張し、カスタム登録フローを提供します
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
    end

    protected

    # サインアップ後のリダイレクト先
    def after_sign_up_path_for(resource)
      # 必ず確認メール待ちのページへ
      new_user_session_path
    end

    # 非アクティブなユーザー登録後のリダイレクト先（メール認証が必要な場合など）
    def after_inactive_sign_up_path_for(resource)
      # サインアップ成功メッセージを表示するページへ
      new_user_session_path
    end
  end
end

# ログインユーザー向けトップページを担当するコントローラー
# ログイン後のホーム画面表示機能を提供します
class TopPageLoginController < ApplicationController
  before_action :authenticate_user!

  def top; end
end

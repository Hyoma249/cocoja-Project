class StaticPagesGuestController < ApplicationController
  # ログイン済みユーザーのリダイレクト処理を:topアクションの前に実行
  before_action :redirect_if_authenticated, only: [:top]

  def top
    # トップページの処理
  end

  private

  def redirect_if_authenticated
    # ユーザーがログインしている場合、ログインユーザー用のトップページへリダイレクト
    redirect_to top_page_login_url(protocol: 'https') if user_signed_in?
  end
end

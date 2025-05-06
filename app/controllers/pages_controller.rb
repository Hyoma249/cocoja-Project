class PagesController < ApplicationController
  # 利用規約とプライバシーポリシーは未ログインでもアクセス可能
  skip_before_action :authenticate_user!, only: [:terms, :privacy]

  def terms
    # 利用規約ページの表示
  end

  def privacy
    # プライバシーポリシーページの表示
  end
end

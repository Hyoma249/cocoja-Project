class PagesController < ApplicationController
  # 利用規約とプライバシーポリシーは未ログインでもアクセス可能
  skip_before_action :authenticate_user!, only: [:contact, :terms, :privacy]

  def contact
    # お問い合わせページの表示
  end

  def terms
    # 利用規約ページの表示
  end

  def privacy
    # プライバシーポリシーページの表示
  end
end

class StaticPagesGuestController < ApplicationController
  before_action :redirect_if_authenticated, only: [:top]

  def top
    # 既存のアクション内容
  end
end

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:guide]
  
  def guide
    # ガイドページの表示
    # 特別な処理が必要ない場合はこのままで問題ありません
  end
end

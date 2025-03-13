class PostsController < ApplicationController
  # 新規投稿フォーム
  def new
    @prefectures = Prefecture.all

    # デバッグ用：取得した都道府県の数を確認
    puts "取得した都道府県の数: #{@prefectures.count}"
  end
end

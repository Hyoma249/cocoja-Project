# 投稿とハッシュタグの中間テーブルモデル
class PostHashtag < ApplicationRecord
  belongs_to :post
  belongs_to :hashtag
end

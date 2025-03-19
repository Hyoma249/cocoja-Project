class Prefecture < ApplicationRecord
  # 都道府県は たくさんの投稿 を持てる
  has_many :posts
  # バリデーション
  validates :name, presence: true, uniqueness: true
end
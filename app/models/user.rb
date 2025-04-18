class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :confirmable メール認証を有効にする場合はコメントアウトを外す
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ユーザーは たくさんの投稿 を持てる
  has_many :posts

  # Active Storageの代わりにCarrierWaveを使用
  mount_uploader :profile_image_url, ProfileImageUploader

  # バリデーションの修正
  validates :username, presence: true,
                      length: { minimum: 1, maximum: 20 },
                      uniqueness: true,
                      on: :update

  validates :uid, presence: true,
                 format: { with: /\A[a-zA-Z0-9]+\z/, message: 'は半角英数字のみ使用できます' },
                 length: { minimum: 6, maximum: 15 },
                 uniqueness: true,
                 on: :update

  validates :bio, length: { maximum: 160 }, allow_blank: true
end

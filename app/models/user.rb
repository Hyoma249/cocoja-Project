class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :confirmable メール認証を有効にする場合はコメントアウトを外す
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ユーザーは たくさんの投稿 を持てる
  has_many :posts
  has_many :votes, dependent: :destroy

  # 今日投票したポイントの合計
  def daily_votes_count
    votes.today.sum(:points)
  end
  # 今日の残り投票ポイント
  def remaining_daily_points
    [0, 5 - daily_votes_count].max
  end
  # 今日の残り投票ポイントを加算しても大丈夫か
  def can_vote?(points_to_add)
    remaining_daily_points >= points_to_add
  end

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

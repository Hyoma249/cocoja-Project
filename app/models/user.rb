class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :confirmable メール認証を有効にする場合はコメントアウトを外す
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # アソシエーション
  # ユーザーは たくさんの投稿 を持てる
  has_many :posts, dependent: :destroy
  has_many :votes, dependent: :destroy
  # フォローしている関連付け
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # フォローされている関連付け
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # フォローしているユーザーを取得
  has_many :followings, through: :active_relationships, source: :followed
  # フォロワーを取得
  has_many :followers, through: :passive_relationships, source: :follower

  # メソッド一覧
  # 今日投票したポイントの合計
  def daily_votes_count
    votes.today.sum(:points)
  end
  # 今日の残り投票ポイント
  def remaining_daily_points
    [ 0, 5 - daily_votes_count ].max
  end
  # 今日の残り投票ポイントを加算しても大丈夫か
  def can_vote?(points_to_add)
    remaining_daily_points >= points_to_add
  end

  # 指定したユーザーをフォローする
  def follow(user)
    return if following?(user)  # 既にフォローしている場合は何もしない
    active_relationships.create(followed_id: user.id)
  end

  # 指定したユーザーのフォローを解除する
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end

  # 指定したユーザーをフォローしているかどうかを判定
  def following?(user)
    followings.include?(user)
  end

  # Active Storageの代わりにCarrierWaveを使用
  mount_uploader :profile_image_url, ProfileImageUploader

  # バリデーション
  validates :username, presence: true,
                      length: { minimum: 1, maximum: 20 },
                      uniqueness: true,
                      on: :update

  validates :uid, presence: true,
                 format: { with: /\A[a-zA-Z0-9]+\z/, message: "は半角英数字のみ使用できます" },
                 length: { minimum: 6, maximum: 15 },
                 uniqueness: true,
                 on: :update

  validates :bio, length: { maximum: 160 }, allow_blank: true
end

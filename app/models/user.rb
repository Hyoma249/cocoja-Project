# ユーザー情報を管理するモデル
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2] # Google認証を追加

  # アソシエーション
  # ユーザーは たくさんの投稿 を持てる
  has_many :posts, dependent: :destroy
  has_many :votes, dependent: :destroy
  # フォローしている関連付け
  has_many :active_relationships, class_name: 'Relationship',
                                 foreign_key: 'follower_id',
                                 dependent: :destroy,
                                 inverse_of: :follower
  # フォローされている関連付け
  has_many :passive_relationships, class_name: 'Relationship',
                                  foreign_key: 'followed_id',
                                  dependent: :destroy,
                                  inverse_of: :followed
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
    [0, 5 - daily_votes_count].max
  end

  # 指定したポイント数の投票が可能かどうか
  def can_vote?(points_to_add)
    remaining_daily_points >= points_to_add.to_i
  end

  # 特定の投稿に今日投票済みかチェック
  def voted_today_for?(post)
    # 日付に関わらず投票済みかを最初にチェック（より高速）
    return true if voted_for?(post)

    # 念のため日付指定でも確認
    votes.today.exists?(post_id: post.id)
  end

  # 特定の投稿に投票済みかチェック（日付に関わらず）
  def voted_for?(post)
    votes.exists?(post_id: post.id)
  end

  # 指定したユーザーをフォローする
  def follow(user)
    return if following?(user) # 既にフォローしている場合は何もしない

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

  # OmniAuth認証からのユーザー作成・検索
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid_from_provider: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]

      # username と uid の事前設定は行わない
      # ユーザーがプロフィール設定画面で自分で入力する

      # リモート画像URLを設定（CarrierWaveのリモートURLメソッドを使用）
      if auth.info.image.present?
        user.remote_profile_image_url_url = auth.info.image
      end

      # Google認証の場合はメール確認を自動的に完了させる
      user.skip_confirmation!
      user.confirm
    end
  end

  # Active Storageの代わりにCarrierWaveを使用
  mount_uploader :profile_image_url, ProfileImageUploader

  # バリデーション
  validates :username, presence: true,
                      length: { minimum: 1, maximum: 20 },
                      uniqueness: true,
                      on: :update

  validates :uid, presence: true,
                 format: { with: /\A[a-zA-Z0-9]+\z/, message: :invalid_format },
                 length: { minimum: 6, maximum: 15 },
                 uniqueness: true,
                 on: :update

  validates :bio, length: { maximum: 160 }, allow_blank: true
end

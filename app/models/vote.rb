# ユーザーの投票を管理するモデル
class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :points, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: 5
  }

  validates :user_id, uniqueness: {
    scope: [:post_id, :voted_on],
    message: '同じ投稿には1日1回しかポイントを付けられません'
  }

  validate :daily_point_limit
  validate :cannot_vote_own_post

  scope :today, -> { where(voted_on: Time.zone.today) }
  scope :for_post, ->(post_id) { where(post_id: post_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :total_points, -> { sum(:points) }

  before_validation :set_voted_on

  private

  def daily_point_limit
    return unless user && points

    return unless points.to_i > user.remaining_daily_points

    errors.add(:points, "1日の投票ポイント上限（5ポイント）を超えています。残り#{user.remaining_daily_points}ポイントです。")
  end

  def cannot_vote_own_post
    return unless user && post
    return unless user_id == post.user_id

    errors.add(:post, '自分の投稿にはポイントを付けられません')
  end

  def set_voted_on
    self.voted_on = Time.zone.today
  end
end

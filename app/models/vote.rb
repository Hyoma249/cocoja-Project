# ユーザーの投票を管理するモデル
class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # 1以上5以下の整数だけを許しますというバリデーション
  validates :points, numericality: {
    only_integer: true, # 整数（小数じゃない）じゃないとダメ
    greater_than: 0, # 0より大きい
    less_than_or_equal_to: 5 # 5以下
  }
  
  # 一意制約をアプリケーションレベルでもチェック
  validates :user_id, uniqueness: { 
    scope: :post_id, 
    message: '同じ投稿には一度しかポイントを付けられません' 
  }
  
  validate :daily_point_limit
  validate :cannot_vote_own_post

  # 今日の投票を取得するスコープ
  scope :today, -> {
    where("DATE(created_at AT TIME ZONE 'UTC') = ?", Time.zone.today)
  }

  private

  # 1日に合計 5ポイントまでしか投票できない
  def daily_point_limit
    return unless user && points

    # 新しい投票を含めた合計を確認
    total_points_today = user.votes.today.sum(:points)
    total_after_vote = total_points_today + points.to_i

    return unless total_after_vote > 5

    errors.add(:points, "1日の投票ポイント上限（5ポイント）を超えています。残り#{5 - total_points_today}ポイントです。")
  end

  # 自分の投稿にはポイントを付けられない
  def cannot_vote_own_post
    return unless user && post
    return unless user_id == post.user_id

    errors.add(:post, '自分の投稿にはポイントを付けられません')
  end
end

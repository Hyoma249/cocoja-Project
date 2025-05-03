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
  validate :daily_point_limit
  validate :cannot_vote_own_post
  validate :not_already_voted_today

  # 1日に投票したレコードを取得するためのスコープ
  # 修正: WhereRange修正
  scope :today, -> { where(created_at: Time.zone.today.beginning_of_day..) }

  private

  # 1日に合計 5ポイントまでしか投票できない
  def daily_point_limit
    return unless user

    total_points_today = user.votes.today.sum(:points)
    remaining_points = 5 - total_points_today

    return unless points > remaining_points # 1日の投票ポイント上限を超えている場合 エラー表示をさせる。

    errors.add(:points, "1日の投票ポイント上限（5ポイント）を超えています。残り#{remaining_points}ポイントです。")
  end

  # 自分の投稿にはポイントを付けられない
  def cannot_vote_own_post
    return unless user && post

    return unless user_id == post.user_id # 自分の投稿に投票しようとした場合

    errors.add(:post, '自分の投稿にはポイントを付けられません')
  end

  # 同じ日に同じ投稿に対して既に投票しているかチェック
  # Naming/PredicateName を修正
  def not_already_voted_today
    return unless user && post

    # 同じ日に同じ投稿に対して既に投票しているかチェック
    return unless user.votes.today.exists?(post_id: post.id) # 既に投票している場合

    errors.add(:post, '同じ投稿に1日に複数回ポイントを付けることはできません')
  end
end

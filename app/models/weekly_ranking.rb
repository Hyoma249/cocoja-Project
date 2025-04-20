class WeeklyRanking < ApplicationRecord
  belongs_to :prefecture

  # これらのデータは絶対に必要！空じゃダメ！
  validates :year, presence: true
  validates :week, presence: true
  validates :rank, presence: true
  validates :points, presence: true

  # 現在の週のランキングを取得するスコープ
  scope :current_week, -> {
    now = Time.zone.now
    year = now.year
    week = now.strftime('%U').to_i
    where(year: year, week: week)
  }

  # 前週のランキングを取得するスコープ
  scope :previous_week, -> {
    prev_week = Time.zone.now - 1.week
    year = prev_week.year
    week = prev_week.strftime('%U').to_i
    where(year: year, week: week)
  }

  # ランキングの順位変動を計算するメソッド
  def rank_change_from_previous
    prev_week = Time.zone.now - 1.week
    prev_year = prev_week.year
    prev_week_num = prev_week.strftime('%U').to_i

    prev_ranking = WeeklyRanking.find_by(
      prefecture_id: prefecture_id,
      year: prev_year,
      week: prev_week_num
    )

    return nil unless prev_ranking

    # 前週の順位 - 今週の順位（正の値：上昇、負の値：下降、0：変動なし）
    prev_ranking.rank - rank
  end
end
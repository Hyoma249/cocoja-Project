class UpdateWeeklyRankingJob < ApplicationJob
  queue_as :default

  def perform
    # 前週の週番号と年を取得
    prev_week = Time.zone.now.beginning_of_week - 1.day
    year = prev_week.year
    week_number = prev_week.strftime('%U').to_i

    # 集計期間の設定
    start_date = prev_week.beginning_of_week
    end_date = prev_week.end_of_week.end_of_day

    # 既存の同じ週のランキングがあれば削除
    WeeklyRanking.where(year: year, week: week_number).destroy_all

    # 都道府県ごとの獲得ポイントを集計
    prefecture_points = {}
    Prefecture.all.each do |prefecture|
      points = prefecture.weekly_points(start_date, end_date)
      prefecture_points[prefecture.id] = points
    end

    # ポイント降順でソート
    ranked_prefectures = prefecture_points.sort_by { |_, points| -points }

    # ランキングを保存
    ActiveRecord::Base.transaction do
      ranked_prefectures.each_with_index do |(prefecture_id, points), index|
        next if points == 0 # ポイントが0の場合はランキングに含めない

        WeeklyRanking.create!(
          prefecture_id: prefecture_id,
          year: year,
          week: week_number,
          rank: index + 1,
          points: points
        )
      end
    end

    # ログ出力
    Rails.logger.info "Weekly ranking updated for Year: #{year}, Week: #{week_number}"
  end
end
# 週間ランキング情報を定期的に更新するジョブ
class UpdateWeeklyRankingJob < ApplicationJob
  queue_as :default

  def perform
    @year, @week_number, @start_date, @end_date = previous_week_info

    # 既存の同じ週のランキングがあれば削除
    clear_existing_rankings

    # 一括クエリで都道府県ごとのポイントを取得
    prefecture_points = Prefecture.weekly_points_for_all(@start_date, @end_date)

    # 都道府県情報をプリロード
    prefectures = Prefecture.all.index_by(&:id)

    # ランキングを作成して保存
    create_rankings(prefecture_points)

    # ログ出力
    Rails.logger.info "Weekly ranking updated for Year: #{@year}, Week: #{@week_number}"
  end

  private

  # 前週の情報（年、週番号、開始日、終了日）を取得
  def previous_week_info
    prev_week = Time.zone.now.beginning_of_week - 1.day
    year = prev_week.year
    week_number = prev_week.strftime('%U').to_i
    start_date = prev_week.beginning_of_week
    end_date = prev_week.end_of_week.end_of_day

    [year, week_number, start_date, end_date]
  end

  # 既存のランキングをクリア
  def clear_existing_rankings
    WeeklyRanking.where(year: @year, week: @week_number).destroy_all
  end

  # ランキングデータを作成して保存
  def create_rankings(prefecture_points)
    # ポイント降順でソート
    ranked_prefectures = prefecture_points.sort_by { |_, points| -points }

    ActiveRecord::Base.transaction do
      ranked_prefectures.each_with_index do |(prefecture_id, points), index|
        next if points.zero? # ポイントが0の場合はランキングに含めない

        WeeklyRanking.create!(
          prefecture_id: prefecture_id,
          year: @year,
          week: @week_number,
          rank: index + 1,
          points: points
        )
      end
    end
  end
end

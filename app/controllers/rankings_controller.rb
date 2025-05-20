class RankingsController < ApplicationController
  def index
    @current_rankings = Rails.cache.fetch("current_rankings", expires_in: 1.hour) do
      rankings = WeeklyRanking.current_week.includes(:prefecture).order(rank: :asc)

      if rankings.empty?
        calculate_current_rankings
      else
        rankings.map do |ranking|
          { prefecture: ranking.prefecture, rank: ranking.rank, points: ranking.points }
        end
      end
    end

    @previous_rankings = Rails.cache.fetch("previous_rankings", expires_in: 1.day) do
      WeeklyRanking.previous_week.includes(:prefecture).order(rank: :asc).map do |ranking|
        { prefecture: ranking.prefecture, rank: ranking.rank, points: ranking.points }
      end
    end
  end

  private

  def calculate_current_rankings
    start_date = Time.zone.now.beginning_of_week
    end_date = Time.zone.now

    prefecture_points = calculate_prefecture_points(start_date, end_date)

    sorted_prefectures = prefecture_points.values.sort_by { |p| -p[:points] }

    result = sorted_prefectures.map.with_index do |data, index|
      { prefecture: data[:prefecture], rank: index + 1, points: data[:points] }
    end

    result
  end

  def calculate_prefecture_points(start_date, end_date)
    prefecture_points = {}
    prefectures_with_points = Prefecture.with_points_between(start_date, end_date).to_a

    Prefecture.all.each do |prefecture|
      pref_with_points = prefectures_with_points.find { |p| p.id == prefecture.id }
      points = pref_with_points ? pref_with_points.weekly_points.to_i : 0
      prefecture_points[prefecture.id] = { prefecture: prefecture, points: points }
    end

    prefecture_points
  end
end

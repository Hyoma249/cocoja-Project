# ユーザーテーブルから不要になった remaining_daily_points カラムを削除するマイグレーション
class RemoveRemainingDailyPointsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :remaining_daily_points, :integer
  end
end

# 週間ランキングテーブルを作成するマイグレーション
class CreateWeeklyRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_rankings do |t|
      t.references :prefecture, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :week, null: false
      t.integer :rank, null: false
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    add_index :weekly_rankings, %i[year week rank], unique: true
  end
end

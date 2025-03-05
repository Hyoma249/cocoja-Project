class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :username, null: false
      t.string :uid, null: false
      t.references :user, null: false, foreign_key: true # usersテーブルとのアソシエーション（外部キーの参照）

      t.timestamps # created_at, updated_atカラムの作成
    end
  end
end

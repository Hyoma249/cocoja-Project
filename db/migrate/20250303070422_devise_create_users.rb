# Deviseを使用したユーザーテーブルを作成するマイグレーション
class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  # メソッドを分割して複雑さを軽減
  def change
    # ユーザーテーブルの作成
    create_user_table

    # インデックスの追加
    add_user_indexes
  end

  private

  # ユーザーテーブルとそのカラム作成
  def create_user_table
    create_table :users do |t|
      # Devise認証カラム
      add_authentication_columns(table: t)

      # 追加のDevise機能カラム
      add_additional_devise_columns(table: t)

      # カスタムフィールド
      add_custom_user_fields(table: t)

      # タイムスタンプ
      t.timestamps null: false
    end
  end

  # 認証関連のカラム
  def add_authentication_columns(table:)
    table.string :email,              null: false
    table.string :encrypted_password, null: false
    table.string :reset_password_token
    table.datetime :reset_password_sent_at
    table.datetime :remember_created_at
  end

  # 追加のDevise機能のカラム（コメントアウト状態）
  def add_additional_devise_columns(table:)
    # Trackable（トラッキング）
    # table.integer  :sign_in_count, default: 0, null: false
    # table.datetime :current_sign_in_at
    # table.datetime :last_sign_in_at
    # table.string   :current_sign_in_ip
    # table.string   :last_sign_in_ip

    # Confirmable（メール確認）
    # table.string   :confirmation_token
    # table.datetime :confirmed_at
    # table.datetime :confirmation_sent_at
    # table.string   :unconfirmed_email
  end

  # カスタムユーザーフィールド
  def add_custom_user_fields(table:)
    table.string :username
    table.string :uid
    table.string :profile_image_url
  end

  # 必要なインデックスを追加
  def add_user_indexes
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    add_index :users, :username,             unique: true
    add_index :users, :uid,                  unique: true
  end
end

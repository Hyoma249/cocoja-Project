class AddPrefectureData < ActiveRecord::Migration[7.1]
  def up
    insert_prefecture_data
  end

  def down
    Prefecture.delete_all
  end

  private

  def insert_prefecture_data
    ActiveRecord::Base.transaction do
      unless Prefecture.count.positive?
        prefectures = prefecture_master_data

        insert_prefecture_batches(prefectures)
      end
    end
  end

  def prefecture_master_data
    %w[
      北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
      茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
      新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
      静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県
      奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県
      徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県
      熊本県 大分県 宮崎県 鹿児島県 沖縄県
    ]
  end

  def insert_prefecture_batches(prefectures)
    prefectures.each_slice(10) do |prefecture_group|
      values = prefecture_group.map { |name| "('#{name}', NOW(), NOW())" }.join(', ')
      ActiveRecord::Base.connection.execute(
        "INSERT INTO prefectures (name, created_at, updated_at) VALUES #{values}"
      )
    end
  end
end

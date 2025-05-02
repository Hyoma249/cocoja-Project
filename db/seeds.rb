# db/seeds.rb
Rails.logger.info 'シードデータの投入を開始します...'

prefectures = %w[
  北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
  茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
  新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
  静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県
  奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県
  徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県
  熊本県 大分県 宮崎県 鹿児島県 沖縄県
]

Rails.logger.info "投入する都道府県データ: #{prefectures.size}件"

prefectures.each_with_index do |name, index|
  prefecture = Prefecture.find_or_create_by!(name: name)
  Rails.logger.info "#{index + 1}. #{name} - 作成完了 (ID: #{prefecture.id})"
rescue StandardError => e
  Rails.logger.error "#{index + 1}. #{name} - エラー: #{e.message}"
end

result_count = Prefecture.count
Rails.logger.info "シードデータの投入完了。データベース内の都道府県数: #{result_count}件"

if result_count == prefectures.size
  Rails.logger.info '✅ 成功: すべての都道府県データが正常に保存されました。'
else
  Rails.logger.warn '❌ 警告: 保存された都道府県数が予想と一致しません。'
end

# MiniMagickの設定最適化

# 高速化設定
MiniMagick.configure do |config|
  # GraphicsMagickを使用したい場合は正しい方法で確認
  begin
    # シェルコマンドでgmの存在確認
    gm_exists = system("which gm > /dev/null 2>&1")
    config.cli = :graphicsmagick if gm_exists
  rescue
    # エラー時はデフォルト設定を使用
  end

  # 短いタイムアウト
  config.timeout = 5
end

# ログレベルを抑制（処理速度向上）
MiniMagick.logger.level = Logger::WARN if defined?(MiniMagick.logger)

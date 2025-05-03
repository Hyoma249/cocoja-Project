# Turboフレームのレスポンスを最適化するための設定

# キャッシュヘッダーを調整
Rails.application.config.action_controller.perform_caching = true

# TurboフレームのHTTPレスポンスを最適化するためのモジュール
module TurboFrameResponseOptimizer
  extend ActiveSupport::Concern

  included do
    # Turboフレームリクエストにキャッシュヘッダーを設定
    after_action :set_turbo_frame_cache_headers, if: -> { request.headers['Turbo-Frame'].present? }
  end

  private

  def set_turbo_frame_cache_headers
    # ブラウザキャッシュを短時間有効にする
    response.headers['Cache-Control'] = 'private, max-age=60'
    response.headers['Vary'] = 'Turbo-Frame'
  end
end

# ApplicationControllerに機能を追加
ActiveSupport.on_load(:action_controller) do
  include TurboFrameResponseOptimizer
end

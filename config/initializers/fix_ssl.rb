class FixSSL
  def initialize(app)
    @app = app
  end

  def call(env)
    # X-Forwarded-Protoヘッダーを確認
    if env['HTTP_X_FORWARDED_PROTO'] == 'https'
      # 環境変数を明示的にHTTPSに設定
      env['HTTPS'] = 'on'
      env['rack.url_scheme'] = 'https'
      env['REQUEST_SCHEME'] = 'https'

      # コンテナ内では実際のリクエストはHTTPかもしれないが、
      # クライアントからはHTTPSで来ていることをRailsに伝える
      env['HTTP_X_FORWARDED_SSL'] = 'on'
      env['HTTP_X_FORWARDED_PROTO'] = 'https'
    end

    # 続けて処理
    @app.call(env)
  end
end

# ミドルウェアとして追加（最も早い段階で実行されるように）
Rails.application.config.middleware.insert_before 0, FixSSL
# より安全な設定
OmniAuth.config.allowed_request_methods = [:post]

# 本番環境用の正確なホスト名を設定（HTTPSを使用）
if Rails.env.production?
  OmniAuth.config.full_host = 'https://www.cocoja.jp/'
end

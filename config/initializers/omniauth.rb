OmniAuth.config.allowed_request_methods = [:post]

if Rails.env.production?
  OmniAuth.config.full_host = 'https://www.cocoja.jp/'
end

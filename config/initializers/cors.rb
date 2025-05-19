Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      origins 'localhost:3000'
    else
      origins ENV.fetch('ALLOWED_ORIGINS') {
        'https://www.cocoja.jp/'
      }
    end

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end

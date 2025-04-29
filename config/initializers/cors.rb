Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      origins "localhost:3000"
    else
      # Back4appの実際のドメインを指定
      origins ENV.fetch("ALLOWED_ORIGINS") {
        "https://cocoja-7b01rrht.b4a.run"
      }
    end

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end

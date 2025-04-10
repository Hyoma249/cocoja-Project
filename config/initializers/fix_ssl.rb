class FixSSL
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_X_FORWARDED_PROTO'] == 'https'
      env['HTTPS'] = 'on'
      env['rack.url_scheme'] = 'https'
      env['REQUEST_SCHEME'] = 'https'
    end

    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before ActionDispatch::Static, FixSSL
# 例: config/initializers/smtp_settings.rb
if Rails.env.production?
  begin
    test_smtp = Net::SMTP.new('smtp.gmail.com', 587)
    test_smtp.enable_starttls_auto
    test_smtp.start('cocoja-7b01rrht.b4a.run',
                    Rails.application.credentials.dig(:gmail, :username),
                    Rails.application.credentials.dig(:gmail, :password),
                    :login)
    test_smtp.finish
    Rails.logger.info "SMTP connection test: Success"
  rescue => e
    Rails.logger.error "SMTP connection test failed: #{e.message}"
  end
end
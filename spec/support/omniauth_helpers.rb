module OmniauthHelpers
  def mock_google_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          name: 'Test User',
          image: 'https://example.com/test_image.jpg'
        },
        credentials: {
          token: 'mock_token',
          expires_at: Time.now + 1.week,
          expires: true
        }
      }
    )
  end

  def mock_invalid_google_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  end

  def disable_omniauth_csrf_protection
    OmniAuth.config.request_validation_phase = nil
  end

  def setup_omniauth_error_handling
    OmniAuth.config.on_failure = proc { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end

  def setup_omniauth_test_environment
    OmniAuth.config.test_mode = true
    disable_omniauth_csrf_protection
    setup_omniauth_error_handling
    mock_google_auth_hash
  end

  def reset_omniauth_test_environment
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end

RSpec.configure do |config|
  config.include OmniauthHelpers

  config.before(:suite) do
    OmniAuth.config.test_mode = true
    OmniAuth.config.request_validation_phase = nil
  end

  config.after(:suite) do
    OmniAuth.config.test_mode = false
  end

  config.before(:each, omniauth: true) do
    setup_omniauth_test_environment
  end

  config.after(:each, omniauth: true) do
    reset_omniauth_test_environment
  end
end

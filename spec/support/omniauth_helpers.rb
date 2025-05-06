# OmniAuth認証関連のテストヘルパーモジュール
module OmniauthHelpers
  # GoogleのOAuth認証をモック
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

  # 認証に失敗するシナリオをモック
  def mock_invalid_google_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  end

  # OmniAuthリクエストのCSRF保護を無効化（テスト環境用）
  def disable_omniauth_csrf_protection
    OmniAuth.config.request_validation_phase = nil
  end

  # エラーハンドリング設定
  def setup_omniauth_error_handling
    OmniAuth.config.on_failure = proc { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end

  # OmniAuthのテスト環境をセットアップ
  def setup_omniauth_test_environment
    OmniAuth.config.test_mode = true
    disable_omniauth_csrf_protection
    setup_omniauth_error_handling
    mock_google_auth_hash
  end

  # OmniAuth環境の設定をリセット
  def reset_omniauth_test_environment
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end

# RSpec設定に組み込む
RSpec.configure do |config|
  config.include OmniauthHelpers

  # テスト全体でOmniAuthのテストモードを有効にする
  config.before(:suite) do
    OmniAuth.config.test_mode = true
    OmniAuth.config.request_validation_phase = nil
  end

  # テスト後に設定をリセット
  config.after(:suite) do
    OmniAuth.config.test_mode = false
  end

  # omniauth: trueメタデータを持つテストで自動的にセットアップ
  config.before(:each, omniauth: true) do
    setup_omniauth_test_environment
  end

  # omniauth: trueメタデータを持つテストの後にリセット
  config.after(:each, omniauth: true) do
    reset_omniauth_test_environment
  end
end

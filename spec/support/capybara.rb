require 'capybara/rspec'     # CapybaraとRSpecを連携させるために必要
require 'selenium-webdriver' # ブラウザの自動操作のために必要

RSpec.configure do |config|
  # 通常のシステムテスト設定
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # JavaScriptを使用するテストの設定
  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

require 'capybara/rspec'
require 'selenium-webdriver'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5

require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mypage_url
    assert_response :success
  end
end

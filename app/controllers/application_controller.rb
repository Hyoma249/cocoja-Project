class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    top_page_login_url(protocol: 'https')
  end
end

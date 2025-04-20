class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    top_page_login_url(protocol: 'https')
  end

  private

  def redirect_if_authenticated
    if user_signed_in?
      redirect_to top_page_login_path
    end
  end
end
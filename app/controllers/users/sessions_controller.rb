module Users
  class SessionsController < Devise::SessionsController
    def destroy
      super do
        return redirect_to root_url(protocol: 'https'), notice: t('controllers.users.sessions.signed_out')
      end
    end

    protected

    def after_sign_in_path_for(_resource)
      flash[:notice] = t('controllers.users.sessions.signed_in')
      top_page_login_url(protocol: 'https')
    end
  end
end

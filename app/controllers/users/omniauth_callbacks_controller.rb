module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      handle_auth('Google')
    end

    private

    def handle_auth(kind)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        unless @user.confirmed?
          @user.confirm
          @user.save
        end
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind

        if @user.username.blank? || @user.uid.blank?
          sign_in @user, event: :authentication
          redirect_to profile_setup_path
        else
          sign_in_and_redirect @user, event: :authentication
        end
      else
        session["devise.#{kind.downcase}_data"] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end
  end
end

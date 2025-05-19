module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def after_confirmation_path_for(resource_name, resource)
      sign_in(resource)
      profile_setup_path
    end
  end
end

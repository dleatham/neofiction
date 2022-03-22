class RegistrationsController < Devise::RegistrationsController

    def create
      if verify_recaptcha
        super
      else
        build_resource
        clean_up_passwords(resource)
        flash.now[:alert] = "Sorry, the reCaptcha code you entered was not correct. Please enter your password and the code again."
        render_with_scope :new
      end
    end
  end
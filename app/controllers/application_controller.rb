class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  class AccessControlError < StandardError
  end
  
  if Rails.env.production?
    rescue_from CanCan::AccessDenied,
                AccessControlError,
                 :with => :access_control_error
    
    rescue_from ActiveRecord::RecordNotFound, 
                ActionController::UnknownAction, 
                ActionController::UnknownController,
                ActionController::RoutingError,
                :with => :general_error
  end
    
  rescue_from User::EULANotAgreed, :with => :send_to_eula_page
  rescue_from User::UpdateEulaFailed, :with => :eula_failed

    
  
  ################################################################
  # overriding the current ability so that it can be called in story and chapter models
  # https://github.com/ryanb/cancan/wiki/ability-for-other-users
  
  def current_ability
    current_user ||= User.new
    current_user.ability
    
  end
    
  private
  
  ################################################################
  # redirect to the eula page
  def send_to_eula_page
    flash[:error] = "You must agree to the licence agreement before creating a story or chapter."
    redirect_to pages_license_path
  end
  
  ##################################################################
  #  redirect back to the previous page
  def eula_failed
    flash[:error] = "An error occured.  The license agreement status could not be updated."
    redirect_to :back
  end
  
  ##################################################################
  #  handle a general error
  def general_error(exception)
    logger.error(exception)
    flash[:error] = "An error occured.  If this continues, please contact neoFICTION Support.  " + "(error: " + exception.to_s + ")"
    redirect_to :root
  end
  
  # handle an access control error
  def access_control_error(exception)
    logger.error(exception)
    flash[:error] = "You do not have sufficient access privileges!"
    redirect_to root_url
  end
  
end

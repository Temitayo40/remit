class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: %i[ new create ]
  # Slows down password guessing: max 10 login attempts per IP every 3 minutes.
  rate_limit to:10, within: 3.minutes, only: %i[ create ], with: -> {
    redirect_to new_session_path, alert: "Too many login attempts. Try again in a few minutes."
  }

  helper_method :login_method

  def new
  end

  def create
    if user = User.authenticate_by(credentials) #by email and password or by phone and password
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path(with: login_method), alert: "Try another #{identifier_label} or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

    def login_method
      params[:with] == "email" ? "email" : "phone"
    end

    def identifier_field
      login_method == "email" ? :email_address : :phone
    end

    def identifier_label
      login_method == "email" ? "email address" : "phone number"
    end

    def credentials
      permitted = params.permit(identifier_field, :password)
      { identifier_field => permitted[identifier_field], password: permitted[:password] }
    end
end

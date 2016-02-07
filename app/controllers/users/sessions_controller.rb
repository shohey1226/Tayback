class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  skip_before_filter :verify_signed_out_user
  protect_from_forgery :except => [:destroy]
  acts_as_token_authentication_handler_for User


  def create
     warden.authenticate!(:scope => resource_name)
     @user = current_user
     render json: {token: @user.authentication_token}
  end

  # DELETE /logout
  def destroy
    if user_signed_in?
      @user = current_user
      @user.authentication_token = nil
      @user.save
      render json: { success: true }
    else
      render json: { message: 'failure' }
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end

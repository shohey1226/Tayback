class Users::SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]
  skip_before_filter :verify_signed_out_user
  #protect_from_forgery :except => [:destroy, :create]
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User
  respond_to :json

  def create
    warden.authenticate!(:scope => resource_name)
    current_user.update!(locale: login_params[:locale])
    render json: {
      message: 'Log in successfully',
      data: {
        id: current_user.id,
        username: current_user.username,
        email: current_user.email,
        token: current_user.authentication_token,
        locale: current_user.locale,
        urlList: current_user.url_list
      }
    }
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

  private

    def login_params
      params.require(:user).permit(:login, :password, :locale)
    end
end

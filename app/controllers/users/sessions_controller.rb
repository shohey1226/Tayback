class Users::SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]
  skip_before_filter :verify_signed_out_user
  protect_from_forgery :except => [:destroy, :create]
  acts_as_token_authentication_handler_for User

  def create

    #
    # logger.warn "*** BEGIN RAW REQUEST HEADERS ***"
    # self.request.env.each do |header|
    #   logger.warn "HEADER KEY: #{header[0]}"
    #   logger.warn "HEADER VAL: #{header[1]}"
    # end
    # logger.warn "*** END RAW REQUEST HEADERS ***"

    #resource = warden.authenticate!(:scope => resource_name, :store => is_navigational_format?)

    warden.authenticate!(:scope => resource_name)
    render json: {
      message: 'Log in successfully',
      data: {
        username: current_user.username,
        email: current_user.email,
        token: current_user.authentication_token,
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
    def set_user
      @user = User.find_by(username: params[:username])
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end
end

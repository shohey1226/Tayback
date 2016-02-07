class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  protect_from_forgery :except => [:create]
  respond_to :json
  acts_as_token_authentication_handler_for User

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /register
  def create
    ActiveRecord::Base.transaction do
      begin
        @user = build_resource(user_params)
        if resource.save
          @success = true
        else
          clean_up_passwords resource
          @success = false
          @errors = resource.errors
          raise t('.invalid_signup')
        end
      rescue Exception => e
        @success = false
        @errors = e.message if @errors.blank? and not e.message.nil?
        raise ActiveRecord::Rollback
      end
    end
    #super
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password)
    end
end

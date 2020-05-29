class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user,
                :check_expiration, only: %i(edit update)

  def new; end

  def edit; end

  # if user_params = true update resetdigest = nil and sucess else render edit
  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t("text_errors_password_empty"))
      render :edit
    elsif @user.update user_params
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = t "text_updated_password_success"
      redirect_to @user
    else
      render :edit
    end
  end

  # create password reset digest and time sent, and sent mail
  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "text_sent_password"
      redirect_to root_url
    else
      flash.now[:danger] = t "text_error_email_not_found"
      render :new
    end
  end

  private

  # load user by email
  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t "error.invalid_ID"
    redirect_to root_url
  end

  # redirect to root_url if user, activated, authenticated = false
  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  # params given from form-for
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "text_password_reset_enpried"
      redirect_to new_password_reset_url
    end
  end
end

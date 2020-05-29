class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update destroy)
  before_action :load_user, except: %i(new index create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show; end

  def index
    @users = User.paginate(page: params[:page], per_page: Settings.per_page)
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "text_activate_info"
      flash[:success] = t "text_welcome"
      redirect_to @user
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = t "text_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  # delete user
  def destroy
    if @user.destroy
      flash[:success] = t "text_deleted"
    else
      flash[:danger] = t "error.delete_user"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "text_pls"
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "text_user_notcorrect"
    redirect_to root_url
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "error.invalid_ID"
    redirect_to root_url
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end

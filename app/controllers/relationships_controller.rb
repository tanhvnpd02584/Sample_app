class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user, only: :create
  before_action :loadrelationship, only: :destroy

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    current_user.unfollow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "error.invalid_ID"
    redirect_to root_url
  end

  def loadrelationship
    @user = Relationship.find_by(id: params[:id]).followed
    return if @user

    flash[:danger] = t "error.invalid_ID"
    redirect_to root_url
  end
end

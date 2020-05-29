class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach params[:micropost] [:image]
    if @micropost.save
      flash[:success] = t "microposts.text_micropost_created"
      redirect_to home_url
    else
      @feed_items = current_user.feed_all.paginate(page: params[:page])
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "microposts.text_micropost_deleted"
      redirect_to request.referer || home_url
    else
      flash[:danger] = t "microposts.text_micropost_cant_delete"
      redirect_to home_url
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to home_url unless @micropost
  end
end

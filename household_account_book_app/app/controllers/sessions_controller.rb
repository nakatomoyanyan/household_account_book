class SessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      flash[:notice] = 'サインインに成功しました'
      redirect_to '/static_pages/home'
    else
      flash[:notice] = 'サインインに失敗しました'
      redirect_to root_path
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end

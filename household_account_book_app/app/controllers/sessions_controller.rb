class SessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])
    flash[:notice] = if @user
                       'サインインに成功しました'
                     else
                       'サインインに失敗しました'
                     end
    redirect_to '/static_pages/home'
  end

  def destroy
    logout
    redirect_to '/static_pages/home'
  end
end

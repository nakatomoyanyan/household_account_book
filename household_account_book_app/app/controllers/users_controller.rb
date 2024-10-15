class UsersController < ApplicationController
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "家計簿アプリへようこそ！"
      redirect_to static_pages_home_url #仮のURL
    else
      render 'new'
    end
  end
  private
    def user_params
       params.require(:user).permit(:user_name, :email, :password, :password_confirmation)
    end
end

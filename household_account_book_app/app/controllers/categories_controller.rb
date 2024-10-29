class CategoriesController < ApplicationController
  before_action :set_user
  before_action :authorize_user
  before_action :set_category, only: [:destroy]

  def new
    @category = @user.categories.new
    @categories = @user.categories.all
  end

  def create
    @category = @user.categories.new(category_params)

    if @category.save
      flash[:notice] = '登録に成功しました'
      redirect_to user_categories_path(@user)
    else
      flash[:notice] = '登録に失敗しました'
      redirect_to user_categories_path(@user)
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = '名目が削除されました'
    redirect_to user_categories_path(@user)
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_category
    @category = @user.categories.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def authorize_user
    unless @user == current_user
      flash[:notice] = 'アクセス権限がありません' 
      redirect_to root_path
    end
  end
end

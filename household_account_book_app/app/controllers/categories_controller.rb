class CategoriesController < ApplicationController
  include UserResourceController
  def new
    @category = user.categories.new
    @categories = user.categories.all
  end

  def create
    @category = user.categories.new(category_params)

    flash[:notice] = if @category.save
                       '登録に成功しました'
                     else
                       '登録に失敗しました'
                     end
    redirect_to user_categories_path(user)
  end

  def destroy
    category.destroy
    flash[:notice] = '名目が削除されました'
    redirect_to user_categories_path(user)
  end

  private

  def category
    @category ||= current_user.categories.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

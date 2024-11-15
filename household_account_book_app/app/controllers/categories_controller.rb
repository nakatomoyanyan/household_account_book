class CategoriesController < ApplicationController
  include UserResourceConcern
  def new
    @category = current_user.categories.new
    @categories = current_user.categories.all
  end

  def create
    @category = current_user.categories.new(category_params)

    flash[:notice] = if @category.save
                       '登録に成功しました'
                     else
                       '登録に失敗しました'
                     end
    redirect_to categories_path(current_user)
  end

  def destroy
    category.destroy
    flash[:notice] = '名目が削除されました'
    redirect_to categories_path(current_user)
  end

  private

  def category
    @category ||= current_user.categories.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

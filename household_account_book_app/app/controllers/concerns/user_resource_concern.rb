module UserResourceConcern
  extend ActiveSupport::Concern

  included do
    before_action :authorize_user
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def authorize_user
    return if user == current_user

    flash[:notice] = 'アクセス権限がありません'
    redirect_to root_path
  end
end

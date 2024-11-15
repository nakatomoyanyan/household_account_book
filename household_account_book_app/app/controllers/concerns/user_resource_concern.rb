module UserResourceConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_login
  end

  private

  def require_login
    return if current_user

    redirect_to root_path, notice: 'ログインしてください'
  end
end

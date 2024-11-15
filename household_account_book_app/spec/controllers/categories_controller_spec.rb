require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:user) { create(:user, email: 'user1@example.com') }
  let(:other_user) { create(:user, email: 'user2@example.com') }
  let!(:category) { create(:category, user:, name: 'test_category') }

  before do
    login_user(user)
  end

  describe 'GET #new' do
    it 'assigns a new category and all categories' do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
      expect(assigns(:categories)).to contain_exactly(category)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new category and redirects to user_categories_path' do
        post :create, params: { user_id: user.id, category: { name: 'food' } }
        expect(user.categories.count).to eq(2)
        expect(flash[:notice]).to eq('登録に成功しました')
        expect(response).to redirect_to(categories_path(user))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new category and redirects to user_categories_path' do
        post :create, params: { user_id: user.id, category: { name: '' } }
        expect(user.categories.count).to eq(1)
        expect(flash[:notice]).to eq('登録に失敗しました')
        expect(response).to redirect_to(categories_path(user))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the category and redirects to user_categories_path' do
      delete :destroy, params: { user_id: user.id, id: category.id }
      expect(user.categories).not_to exist(category.id)
      expect(flash[:notice]).to eq('名目が削除されました')
      expect(response).to redirect_to(categories_path(user))
    end
  end

  describe 'require_login' do
    it 'redirects to root path if user is not the current user' do
      logout_user
      get :new
      expect(flash[:notice]).to eq('ログインしてください')
      expect(response).to redirect_to(root_path)
    end
  end
end

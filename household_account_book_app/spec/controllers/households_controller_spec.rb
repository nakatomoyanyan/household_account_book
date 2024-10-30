require 'rails_helper'

RSpec.describe HouseholdsController, type: :controller do
  let(:user) { FactoryBot.create(:user, email: 'user1@example.com') }
  let(:other_user) { FactoryBot.create(:user, email: 'user2@example.com') }
  let(:category) { FactoryBot.create(:category, user:) }
  let(:valid_attributes) do
    {
      name: 'food',
      date: Date.today,
      amount: 1000,
      category_id: category.id,
      transaction_type: :income
    }
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'assigns a new Household to @household' do
      get :index, params: { user_id: user.id }
      expect(assigns(:household)).to be_a_new(Household)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Household' do
        expect {
          post :create, params: { user_id: user.id, household: valid_attributes }
        }.to change(Household, :count).by(1)
      end

      it 'redirects to the user household index' do
        post :create, params: { user_id: user.id, household: valid_attributes }
        expect(response).to redirect_to(user_households_path(user))
        expect(flash[:notice]).to eq('登録に成功しました')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Household' do
        expect {
          post :create, params: { user_id: user.id, household: { name: '', date: nil } }
        }.to change(Household, :count).by(0)
      end

      it 'redirects to the user household index with an error message' do
        post :create, params: { user_id: user.id, household: { name: '', date: nil } }
        expect(response).to redirect_to(user_households_path(user))
        expect(flash[:notice]).to eq('登録に失敗しました')
      end
    end

    describe 'authorize_user' do
      it 'redirects to root path if user is not the current user' do
        allow(controller).to receive(:current_user).and_return(other_user)
        get :index, params: { user_id: user.id }
        expect(flash[:notice]).to eq('アクセス権限がありません')
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { FactoryBot.create(:user) }
  let(:valid_user_params) do
    {
      email: 'test@example.com',
      password: 'abc1234'
    }
  end

  context 'when #create success' do
    before do
      post :create, params: valid_user_params
    end

    it 'sets a flash message' do
      expect(flash[:notice]).to eq('サインインに成功しました')
    end

    it 'redirects to the home page' do
      expect(response).to redirect_to(user_households_path(user))
    end

    it 'signs in as a user' do
      expect(session[:user_id].to_i).to eq(user.id)
    end
  end

  context 'when #create fails' do
    before do
      post :create, params: { email: '', password: '' }
    end

    it 'sets a flash message' do
      expect(flash[:notice]).to eq('サインインに失敗しました')
    end

    it 'redirects to the home page' do
      expect(response).to redirect_to(root_path)
    end
  end

  context 'DELETE #destroy' do
    before do
      delete :destroy
    end

    it 'logs out the user' do
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the home page' do
      expect(response).to redirect_to(root_path)
    end
  end
end

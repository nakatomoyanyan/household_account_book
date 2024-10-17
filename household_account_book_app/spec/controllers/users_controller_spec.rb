require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    @user = FactoryBot.build(:user)
  end
  let(:valid_user_params) do
    {
      user_name: @user.user_name,
      email: @user.email,
      password: @user.password,
      password_confirmation: @user.password_confirmation
    }
  end
  context 'when #create success' do
    it 'creates a new user' do
      expect {
        post :create, params: { user: valid_user_params }
      }.to change(User, :count).by(1)
    end

    it 'sets a flash message' do
      post :create, params: { user: valid_user_params }
      expect(flash[:success]).to eq("家計簿アプリへようこそ！")
    end

    it 'redirects to the home page' do
      post :create, params: { user: valid_user_params }
      expect(response).to redirect_to(static_pages_home_url)
    end
  end
  context 'when #create fails' do
      it 'does not create a new user' do
        expect {
          post :create, params: { user: { user_name: '', email: '', password: '', password_confirmation: '' } }
        }.not_to change(User, :count)
      end

      it 'renders the new template with unprocessable_entity status' do
        post :create, params: { user: { user_name: '', email: '', password: '', password_confirmation: '' } }
        expect(response).to render_template('new')
        expect(response.status).to eq 422
      end
    end
end

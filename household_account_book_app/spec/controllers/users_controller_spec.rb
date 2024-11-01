require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { build(:user) }
  let(:valid_user_params) do
    {
      user_name: user.user_name,
      email: user.email,
      password: user.password,
      password_confirmation: user.password_confirmation
    }
  end

  context 'when #create success' do
    it 'creates a new user' do
      expect do
        post :create, params: { user: valid_user_params }
      end.to change(User, :count).by(1)
    end

    it 'sets a flash message' do
      post :create, params: { user: valid_user_params }
      expect(flash[:success]).to eq('家計簿アプリへようこそ！')
    end

    it 'redirects to the home page' do
      post :create, params: { user: valid_user_params }
      user = User.last
      expect(response).to redirect_to(user_households_path(user))
    end

    it 'sign in as a user' do
      post :create, params: { user: valid_user_params }
      expect(session[:user_id].to_i).to eq(User.last.id)
    end
  end

  context 'when #create fails' do
    it 'does not create a new user' do
      expect do
        post :create, params: { user: { user_name: '', email: '', password: '', password_confirmation: '' } }
      end.not_to change(User, :count)
    end

    it 'renders the new template with unprocessable_entity status' do
      post :create, params: { user: { user_name: '', email: '', password: '', password_confirmation: '' } }
      expect(response).to render_template('new')
      expect(response.status).to eq 422
    end
  end
end

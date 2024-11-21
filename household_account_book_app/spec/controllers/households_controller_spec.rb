require 'rails_helper'

RSpec.describe HouseholdsController, type: :controller do
  let(:user) { create(:user, email: 'user1@example.com') }
  let(:other_user) { create(:user, email: 'user2@example.com') }
  let(:category) { create(:category, user:) }
  let(:valid_attributes) do
    {
      name: 'food',
      date: Time.zone.today,
      amount: 1000,
      category_id: category.id,
      transaction_type: :income
    }
  end

  before do
    login_user(user)
  end

  describe 'GET #index' do
    before do
      create(:household, transaction_type: 0, date: Time.current, amount: 1000, user:,
                         category:)
      create(:household, transaction_type: 1, date: Time.current, amount: 100, user:,
                         category:)
      create(:household, transaction_type: 2, date: Time.current, amount: 90, user:, category:)
      create(:household, transaction_type: 0, date: 1.month.ago, amount: 1000, user:,
                         category:)
      create(:household, transaction_type: 1, date: 1.month.ago, amount: 100, user:, category:)
      create(:household, transaction_type: 2, date: 1.month.ago, amount: 90, user:, category:)
    end

    it 'assigns a new Household to @household' do
      get :index
      expect(assigns(:household)).to be_a_new(Household)
    end

    it 'assigns @financial_summary_this_year[:total_income]' do
      get :index
      expect(Household.financial_summary_this_year[:total_income]).to eq(2000)
    end

    it 'assigns @financial_summary_this_year[:total_expense]' do
      get :index
      expect(Household.financial_summary_this_year[:total_expense]).to eq(380)
    end

    it 'assigns @financial_summary_this_year[:net_balance]' do
      get :index
      expect(Household.financial_summary_this_year[:net_balance]).to eq(1620)
    end

    it 'assigns @financial_summary_this_month[:total_income]' do
      get :index
      expect(Household.financial_summary_this_month[:total_income]).to eq(1000)
    end

    it 'assigns @financial_summary_this_month[:total_expense]' do
      get :index
      expect(Household.financial_summary_this_month[:total_expense]).to eq(190)
    end

    it 'assigns @financial_summary_this_month[:net_balance]' do
      get :index
      expect(Household.financial_summary_this_month[:net_balance]).to eq(810)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Household' do
        expect do
          post :create, params: { household: valid_attributes }
        end.to change(Household, :count).by(1)
      end

      it 'redirects to the user household index' do
        post :create, params: { household: valid_attributes }
        expect(response).to redirect_to(households_path(user))
        expect(flash[:notice]).to eq('登録に成功しました')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Household' do
        expect do
          post :create, params: { household: { name: '', date: nil } }
        end.not_to change(Household, :count)
      end

      it 'redirects to the user household index with an error message' do
        post :create, params: { household: { name: '', date: nil } }
        expect(flash[:notice]).to eq('登録に失敗しました')
        expect(response).to render_template('index')
        expect(response.status).to eq 422
      end
    end

    describe 'require_login' do
      it 'redirects to root path if user is not the current user' do
        logout_user
        get :index
        expect(flash[:notice]).to eq('ログインしてください')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'get #income' do
    it 'assigns a new index_income_this_year' do
      get :income
      expect(assigns(:incomes_this_year)).to eq(user.households.income.this_year)
    end

    it 'assigns a new incomes_grath_data_this_year' do
      get :income
      expect(assigns(:incomes_grath_data_this_year)).to eq(user.households.income.this_year.group_by_month(:date,
                                                                                                           format: '%B').sum(:amount))
    end

    it 'assigns a new incomes_grath_data_this_month' do
      get :income
      expect(assigns(:incomes_grath_data_this_month)).to eq(user.households.income.this_month.group(:name).sum(:amount))
    end

    describe 'require_login' do
      it 'redirects to root path if user is not the current user' do
        logout_user
        get :income
        expect(flash[:notice]).to eq('ログインしてください')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'get #expense' do
    it 'assigns a new all_expenses_this_year' do
      get :expense
      expect(assigns(:all_expenses_this_year)).to eq(user.households.all_expense.this_year)
    end

    it 'assigns a new expenses_grath_data_this_month' do
      get :expense
      expect(assigns(:all_expenses_grath_data_this_month)).to eq(user.households.all_expense.this_month.group(:name).sum(:amount))
      expect(assigns(:fixed_expenses_grath_data_this_month)).to eq(user.households.fixed_expense.this_month.group(:name).sum(:amount))
      expect(assigns(:variable_expenses_grath_data_this_month)).to eq(user.households.variable_expense.this_month.group(:name).sum(:amount))
    end

    it 'assigns a new expenses_grath_data_this_year' do
      get :expense
      fixed_expenses_data = user.households.fixed_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
      variable_expenses_data = user.households.variable_expense.this_year.group_by_month(:date,
                                                                                         format: '%B').sum(:amount)
      expect(assigns(:expenses_grath_data_this_year)).to eq([{ name: '固定費', data: fixed_expenses_data },
                                                             { name: '流動費', data: variable_expenses_data }])
    end

    describe 'require_login' do
      it 'redirects to root path if user is not the current user' do
        logout_user
        get :expense
        expect(flash[:notice]).to eq('ログインしてください')
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

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
      expect(Household.financial_summary_this_year[:total_income]).to eq(1000)
    end

    it 'assigns @financial_summary_this_year[:total_expense]' do
      get :index
      expect(Household.financial_summary_this_year[:total_expense]).to eq(190)
    end

    it 'assigns @financial_summary_this_year[:net_balance]' do
      get :index
      expect(Household.financial_summary_this_year[:net_balance]).to eq(810)
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

  describe '#index search by ransack' do
    let(:category_1) { create(:category, name: 'Category_1', user:) }
    let(:category_2) { create(:category, name: 'Category_2', user:) }
    let!(:income) do
      create(:household, transaction_type: 0, date: Date.new(2024, 11, 10), amount: 4000, user:, category: category_1)
    end
    let!(:fixed_expense) do
      create(:household, transaction_type: 1, date: Date.new(2024, 11, 5), amount: 4000, user:, category: category_2)
    end
    let!(:variable_expense) do
      create(:household, transaction_type: 2, date: Date.new(2024, 6, 10), amount: 4000, user:, category: category_2)
    end
    let!(:variable_expense_same_day) do
      create(:household, transaction_type: 2, date: Date.new(2024, 6, 10), amount: 4000, user:, category: category_2)
    end

    it 'assigns @years_months' do
      get :index
      expected = [%w[2024 11], %w[2024 06]]
      expect(user.households.distinct_years_months).to eq(expected)
    end

    it 'assigns @q with ransack query' do
      get :index, params: { q: { in_date_range: '2024-11' } }
      expect(assigns(:q)).to be_a(Ransack::Search)
    end

    it 'filters @households by date using ransack' do
      get :index, params: { q: { in_date_range: '2024-11' } }
      expect(assigns(:households)).to contain_exactly(income, fixed_expense)
    end

    it 'filters @households by transaction_type using ransack' do
      get :index, params: { q: { transaction_type_in: 'income' } }
      expect(assigns(:households)).to contain_exactly(income)
    end

    it 'filters @households by category using ransack' do
      get :index, params: { q: { category_id_eq: category_1.id } }
      expect(assigns(:households)).to contain_exactly(income)
    end

    it 'orders @households by date desc and id asc' do
      get :index, params: { q: { in_date_range: '2024-06' } }
      expect(assigns(:households)).to eq([variable_expense, variable_expense_same_day])
    end

    it 'calculates @total_amount_households correctly' do
      get :index, params: { q: { filter_transaction_type: 'expense' } }
      total_amount = fixed_expense.amount + variable_expense.amount + variable_expense_same_day.amount
      expect(assigns(:total_amount_households)).to eq(total_amount)
    end

    context 'when no filters are applied' do
      it 'returns all records for the current user' do
        get :index, params: { q: {} }

        expect(assigns(:households)).to contain_exactly(income, fixed_expense, variable_expense,
                                                        variable_expense_same_day)
      end
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
    let!(:income) do
      create(:household, transaction_type: 0, date: Date.new(2024, 11, 10), amount: 4000, user:, category:,
                         updated_at: '2025-01-08 00:00:00')
    end
    let(:incomes_graph_data_this_month) { { youtube: 77_964, 'アルバイト': 146_489 } }
    let(:incomes_graph_data_this_year) { { '1月': 569_967, '2月': 562_950 } }
    let!(:mock_latest_graph_data) do
      create(
        :incomes_graph,
        user:,
        graph_data_this_month: incomes_graph_data_this_month,
        graph_data_this_year: incomes_graph_data_this_year,
        updated_at: Time.zone.now
      )
    end

    it 'assigns a new @incomes_this_year' do
      get :income
      expect(assigns(:incomes_this_year)).to eq(user.households.income.this_year)
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

  describe 'GET #collecting_incomes_graph_data' do
    let(:incomes_graph_data_this_month) { { youtube: 77_964, 'アルバイト': 146_489 } }
    let(:incomes_graph_data_this_year) { { '1月': 569_967, '2月': 562_950 } }
    let!(:new_income_data) do
      create(:household, transaction_type: 0, date: Date.new(2025, 1, 7), amount: 4000, user:, category:,
                         updated_at: '2025-01-08 00:00:00')
    end

    context 'when incomes_updated_at is greater than or equal to latest_graph_data.updated_at' do
      let!(:mock_latest_graph_data) do
        create(
          :incomes_graph,
          user:,
          graph_data_this_month: incomes_graph_data_this_month,
          graph_data_this_year: incomes_graph_data_this_year,
          updated_at: '2025-01-07 00:00:00'
        )
      end

      it 'renders in_progress status' do
        get :collecting_incomes_graph_data
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']).to eq('in_progress')
      end
    end

    context 'when incomes_updated_at is less than latest_graph_data.updated_at' do
      let!(:mock_latest_graph_data) do
        create(
          :incomes_graph,
          user:,
          graph_data_this_month: incomes_graph_data_this_month,
          graph_data_this_year: incomes_graph_data_this_year,
          updated_at: '2025-01-09 00:00:00'
        )
      end

      it 'renders completed status with HTML content' do
        allow(controller).to receive(:render_to_string).with(
          partial: 'incomes_graph_this_year',
          locals: { incomes_graph_data_this_year: mock_latest_graph_data.graph_data_this_year }
        ).and_return('<div>Yearly Income Graph</div>')

        allow(controller).to receive(:render_to_string).with(
          partial: 'incomes_graph_this_month',
          locals: { incomes_graph_data_this_month: mock_latest_graph_data.graph_data_this_month }
        ).and_return('<div>Monthly Income Graph</div>')

        get :collecting_incomes_graph_data

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']).to eq('completed')
        expect(json_response['html_year']).to eq('<div>Yearly Income Graph</div>')
        expect(json_response['html_month']).to eq('<div>Monthly Income Graph</div>')
      end
    end
  end

  describe 'get #expense' do
    it 'assigns a new all_expenses_this_year' do
      get :expense
      expect(assigns(:all_expenses_this_year)).to eq(user.households.all_expense.this_year)
    end

    it 'assigns a new expenses_graph_data_this_month' do
      get :expense
      expect(assigns(:all_expenses_graph_data_this_month)).to eq(user.households.all_expense.this_month.group(:name).sum(:amount))
      expect(assigns(:fixed_expenses_graph_data_this_month)).to eq(user.households.fixed_expense.this_month.group(:name).sum(:amount))
      expect(assigns(:variable_expenses_graph_data_this_month)).to eq(user.households.variable_expense.this_month.group(:name).sum(:amount))
    end

    it 'assigns a new expenses_graph_data_this_year' do
      get :expense
      fixed_expenses_data = user.households.fixed_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
      variable_expenses_data = user.households.variable_expense.this_year.group_by_month(:date,
                                                                                         format: '%B').sum(:amount)
      expect(assigns(:expenses_graph_data_this_year)).to eq([{ name: '固定費', data: fixed_expenses_data },
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

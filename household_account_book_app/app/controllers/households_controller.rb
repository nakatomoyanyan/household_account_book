class HouseholdsController < ApplicationController
  include UserResourceConcern
  def index
    @household = Household.new
    set_index_variables
  end

  def create
    @household = current_user.households.new(household_params)
    if @household.save
      flash[:notice] = '登録に成功しました'
      redirect_to households_path(current_user)
    else
      flash.now[:notice] = '登録に失敗しました'
      set_index_variables
      render 'index', status: :unprocessable_entity
    end
  end

  def income
    incomes = current_user.households.income
    @incomes_this_year = incomes.this_year.eager_load(:category).decorate
    return unless should_update_incomes_graph?

    IncomesGraphDataJob.perform_later(current_user.id)
  end

  def collecting_incomes_graph_data
    if should_update_incomes_graph?
      render json: { status: 'in_progress' }
    else
      render_incomes_graph_data(current_user.incomes_graph)
    end
  end

  def expense
    households = current_user.households
    @all_expenses_this_year = households.all_expense.this_year.eager_load(:category).decorate
    @all_expenses_graph_data_this_month = households.all_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    @fixed_expenses_graph_data_this_month = households.fixed_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    @variable_expenses_graph_data_this_month = households.variable_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    fixed_expenses_data = households.fixed_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
    variable_expenses_data = households.variable_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
    @expenses_graph_data_this_year = [{ name: '固定費', data: fixed_expenses_data },
                                      { name: '流動費', data: variable_expenses_data }]
  end

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type, images: [])
  end

  def render_incomes_graph_data(_graph_data, status: 'completed')
    html_year = render_to_string(partial: 'incomes_graph_this_year',
                                 locals: { incomes_graph_data_this_year: current_user.incomes_graph.graph_data_this_year })
    html_month = render_to_string(partial: 'incomes_graph_this_month',
                                  locals: { incomes_graph_data_this_month: current_user.incomes_graph.graph_data_this_month })
    render json: { status:, html_year:, html_month: }
  end

  def should_update_incomes_graph?
    incomes_updated_at = current_user.households.income.maximum(:updated_at)
    latest_graph_data = current_user.incomes_graph
    return true if latest_graph_data.nil?

    incomes_updated_at >= latest_graph_data.updated_at
  end

  def set_index_variables
    @financial_summary_this_year = current_user.households.financial_summary_this_year
    @financial_summary_this_month = current_user.households.financial_summary_this_month
    @years_months = current_user.households.distinct_years_months
    params[:q] ||= {}
    @q = current_user.households.ransack(params[:q])
    @total_amount_households = @q.result.sum(:amount)
    @households = @q.result
                    .eager_load(:category)
                    .order(date: :desc, id: :asc)
                    .page(params[:page])
                    .per(50)
  end
end

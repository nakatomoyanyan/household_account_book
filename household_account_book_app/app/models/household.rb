class Household < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :transaction_type, { income: 0, fixed_expense: 1, variable_expense: 2 }
  validates :name, length: { maximum: 20 }, allow_blank: true
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true

  scope :income, lambda {
    where(transaction_type: 0)
  }
  scope :all_expense, lambda {
    where(transaction_type: [1, 2])
  }
  scope :fixed_expense, lambda {
    where(transaction_type: [1])
  }
  scope :variable_expense, lambda {
    where(transaction_type: [2])
  }
  scope :this_year, lambda {
    where(date: Time.current.all_year)
  }
  scope :this_month, lambda {
    where(date: Time.current.all_month)
  }
  scope :in_date_range, lambda { |date|
    if date.present? && date != ''
      year, month = date.split('-').map(&:to_i)
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      where(date: start_date..end_date)
    end
  }
  scope :transaction_type_in, lambda { |transaction_type|
    case transaction_type
    when 'income'
      where(transaction_type: 0)
    when 'expense'
      where(transaction_type: [1, 2])
    else
      all
    end
  }

  scope :category_id_eq, lambda { |category_id|
    where(category_id:) if category_id.present?
  }

  FinancialSummaryStruct = Struct.new(:total_income, :total_expense, :net_balance)

  def self.financial_summary_this_year
    total_income = income.this_year.sum(:amount)
    total_expense = all_expense.this_year.sum(:amount)
    net_balance = total_income - total_expense
    FinancialSummaryStruct.new(total_income:, total_expense:, net_balance:)
  end

  def self.financial_summary_this_month
    total_income = income.this_month.sum(:amount)
    total_expense = all_expense.this_month.sum(:amount)
    net_balance = total_income - total_expense
    FinancialSummaryStruct.new(total_income:, total_expense:, net_balance:)
  end

  def self.ransackable_attributes(auth_object = nil)
    super + ['date']
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[in_date_range transaction_type_in category_id_eq]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category user]
  end

  def self.ransackable_scopes_skip_sanitize_args
    [:category_id_eq]
  end

  def self.distinct_years_months
    select("DISTINCT strftime('%Y', date) AS year, strftime('%m', date) AS month")
      .order('year DESC, month DESC')
      .map { |record| [record.year, record.month] }
  end
end

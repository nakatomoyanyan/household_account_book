class Household < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :transaction_type, { income: 0, fixed_expense: 1, variable_expense: 2 }
  validates :name, length: { maximum: 20 }, allow_blank: true
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true

  scope :income_this_year, lambda {
    where(transaction_type: 0, date: Time.current.all_year)
  }
  scope :expense_this_year, lambda {
    where(transaction_type: [1, 2], date: Time.current.all_year)
  }
  scope :income_this_month, lambda {
    where(transaction_type: 0, date: Time.current.all_month)
  }
  scope :expense_this_month, lambda {
    where(transaction_type: [1, 2], date: Time.current.all_month)
  }

  FinancialSummaryStruct = Struct.new(:total_income, :total_expense, :net_balance)

  def self.financial_summary_this_year
    total_income = income_this_year.sum(:amount)
    total_expense = expense_this_year.sum(:amount)
    net_balance = total_income - total_expense
    FinancialSummaryStruct.new(total_income:, total_expense:, net_balance:)
  end

  def self.financial_summary_this_month
    total_income = income_this_month.sum(:amount)
    total_expense = expense_this_month.sum(:amount)
    net_balance = total_income - total_expense
    FinancialSummaryStruct.new(total_income:, total_expense:, net_balance:)
  end

  def self.index_income_this_year
    income_this_year
  end
end

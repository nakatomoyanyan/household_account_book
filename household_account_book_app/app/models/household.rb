class Household < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :transaction_type, { income: 0, fixed_expense: 1, variable_expense: 2 }
  validates :name, length: { maximum: 20 }, allow_blank: true
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true

  scope :this_year, -> { where(date: Date.current.beginning_of_year..Date.current.end_of_year) }
  scope :this_month, -> { where(date: Date.current.beginning_of_month..Date.current.end_of_month) } 
  scope :income, -> { where(transaction_type: 0) }
  scope :expense, -> { where(transaction_type: [1, 2]) }

  def self.total_income_this_year
    this_year.income.sum(:amount)
  end

  def self.total_expense_this_year
    this_year.expense.sum(:amount)
  end

  def self.net_balance_this_year
    total_income_this_year - total_expense_this_year
  end

  def self.total_income_this_month
    this_month.income.sum(:amount)
  end

  def self.total_expense_this_month
    this_month.expense.sum(:amount)
  end

  def self.net_balance_this_month
    total_income_this_month - total_expense_this_month
  end
end

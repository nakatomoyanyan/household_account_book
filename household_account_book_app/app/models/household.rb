class Household < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :transaction_type, { income: 0, fixed_expense: 1, variable_expense: 2 }
  validates :name, length: { maximum: 20 }, allow_blank: true
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true

  scope :total_income_this_year, lambda {
    where(transaction_type: 0, date: Time.current.all_year)
      .sum(:amount)
  }
  scope :total_expense_this_year, lambda {
    where(transaction_type: [1, 2], date: Time.current.all_year)
      .sum(:amount)
  }
  scope :total_income_this_month, lambda {
    where(transaction_type: 0, date: Time.current.all_month)
      .sum(:amount)
  }
  scope :total_expense_this_month, lambda {
    where(transaction_type: [1, 2], date: Time.current.all_month)
      .sum(:amount)
  }

  def self.financial_summary_this_year
    total_income = total_income_this_year
    total_expense = total_expense_this_year
    {
      total_income:,
      total_expense:,
      net_balance: total_income - total_expense
    }
  end

  def self.financial_summary_this_month
    total_income = total_income_this_month
    total_expense = total_expense_this_month
    {
      total_income:,
      total_expense:,
      net_balance: total_income - total_expense
    }
  end
end

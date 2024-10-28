class Household < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum transaction_type: { income: 0, fixed_expense: 1, variable_expense: 2 }
  validates :name, optional: true
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :amount, presence: true
end

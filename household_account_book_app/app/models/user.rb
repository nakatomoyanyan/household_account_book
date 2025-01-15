class User < ApplicationRecord
  has_many :categories
  has_many :households
  has_one :incomes_grath
  authenticates_with_sorcery!
  validates :password, length: { minimum: 5 }, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true, presence: true
  validates :user_name, presence: true, length: { maximum: 20 }
end

class User < ApplicationRecord
  authenticates_with_sorcery!
  validates :password, length: { minimum: 5 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true, presence: true
  validates :user_name, presence: true, length: { maximum: 20 }
end

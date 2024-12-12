class IncomesGrath < ApplicationRecord
  belongs_to :user
  validates :grath_data_this_month, presence: true
  validates :grath_data_this_year, presence: true
end

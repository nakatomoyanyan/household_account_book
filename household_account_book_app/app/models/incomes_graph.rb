class IncomesGraph < ApplicationRecord
  belongs_to :user
  validates :graph_data_this_month, presence: true
  validates :graph_data_this_year, presence: true
end

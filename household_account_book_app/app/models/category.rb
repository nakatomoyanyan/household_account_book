class Category < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, length: { maximum: 20 }
  def self.ransackable_attributes(auth_object = nil)
    %w[id name user_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    ['user']
  end
end

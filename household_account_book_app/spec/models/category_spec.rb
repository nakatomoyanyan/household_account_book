require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { create(:user) }
  let(:category) { build(:category, user:) }

  describe 'validations' do
    it 'is valid with a name and user' do
      expect(category).to be_valid
    end

    it 'is invalid without a name' do
      category.name = nil
      expect(category).not_to be_valid
    end

    it 'is invalid if name is longer than 20 characters' do
      category.name = 'a' * 21
      expect(category).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end
end

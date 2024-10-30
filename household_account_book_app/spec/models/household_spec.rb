require 'rails_helper'

RSpec.describe Household, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:category) { FactoryBot.build(:category, user:) }

  subject { described_class.new(user: user, category: category) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      subject.name = 'food'
      subject.date = Date.today
      subject.transaction_type = :income
      subject.amount = 1000
      expect(subject).to be_valid
    end

    it 'is not valid without a date' do
      subject.date = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a transaction type' do
      subject.transaction_type = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without an amount' do
      subject.amount = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid with a name longer than 20 characters' do
      subject.name = 'A' * 21
      expect(subject).to_not be_valid
    end
  end
end

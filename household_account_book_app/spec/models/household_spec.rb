require 'rails_helper'

RSpec.describe Household, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:category) { FactoryBot.build(:category, user:) }
  let(:household) { FactoryBot.build(:household, user:, category:) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      household.name = 'food'
      household.date = Time.zone.today
      household.transaction_type = :income
      household.amount = 1000
      expect(household).to be_valid
    end

    it 'is not valid without a date' do
      household.date = nil
      expect(household).not_to be_valid
    end

    it 'is not valid without a transaction type' do
      household.transaction_type = nil
      expect(household).not_to be_valid
    end

    it 'is not valid without an amount' do
      household.amount = nil
      expect(household).not_to be_valid
    end

    it 'is not valid with a name longer than 20 characters' do
      household.name = 'A' * 21
      expect(household).not_to be_valid
    end
  end

  describe 'scopes' do
    before do
      FactoryBot.create(:household, transaction_type: 0, date: Time.current, amount: 4000, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 1, date: Time.current, amount: 1000, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 2, date: Time.current, amount: 2000, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 0, date: Time.current.prev_year, amount: 400, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 1, date: Time.current.prev_year, amount: 100, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 2, date: Time.current.prev_year, amount: 200, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 0, date: Time.current.prev_month, amount: 40, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 1, date: Time.current.prev_month, amount: 10, user:,
                                    category:)
      FactoryBot.create(:household, transaction_type: 2, date: Time.current.prev_month, amount: 20, user:,
                                    category:)
    end

    it 'returns the total income amount from the current year when .total_income_this_year' do
      expect(described_class.total_income_this_year).to eq(4040)
    end

    it 'returns the total expense amount from the current year when .total_expense_this_year' do
      expect(described_class.total_expense_this_year).to eq(3030)
    end

    it 'returns the total income amount from the current month when .total_income_this_month' do
      expect(described_class.total_income_this_month).to eq(4000)
    end

    it 'returns the total expense amount from the current month when .total_expense_this_month' do
      expect(described_class.total_expense_this_month).to eq(3000)
    end
  end
end

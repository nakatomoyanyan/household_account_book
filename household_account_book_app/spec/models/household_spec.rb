require 'rails_helper'

RSpec.describe Household, type: :model do
  let(:user) { create(:user) }
  let(:category) { build(:category, user:) }
  let(:household) { build(:household, user:, category:) }

  let(:variable_expense_last_month) do
    create(:household, transaction_type: 2, date: Time.current.prev_month, amount: 20, user:,
                       category:)
  end
  let(:fixed_expense_last_month) do
    create(:household, transaction_type: 1, date: Time.current.prev_month, amount: 10, user:,
                       category:)
  end
  let(:income_last_month) do
    create(:household, transaction_type: 0, date: Time.current.prev_month, amount: 40, user:,
                       category:)
  end
  let(:variable_expense_last_year) do
    create(:household, transaction_type: 2, date: Time.current.prev_year, amount: 200, user:,
                       category:)
  end
  let(:fixed_expense_last_year) do
    create(:household, transaction_type: 1, date: Time.current.prev_year, amount: 100, user:,
                       category:)
  end
  let(:income_last_year) do
    create(:household, transaction_type: 0, date: Time.current.prev_year, amount: 400, user:,
                       category:)
  end
  let(:variable_expense_this_year) do
    create(:household, transaction_type: 2, date: Time.current, amount: 2000, user:,
                       category:)
  end
  let(:fixed_expense_this_year) do
    create(:household, transaction_type: 1, date: Time.current, amount: 1000, user:,
                       category:)
  end
  let(:income_this_year) do
    create(:household, transaction_type: 0, date: Time.current, amount: 4000, user:,
                       category:)
  end

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
    it 'returns the income when .income' do
      expect(described_class.income).to eq([income_this_year, income_last_month, income_last_year])
    end

    it 'returns the expense when .expense' do
      expect(described_class.expense).to eq([fixed_expense_this_year, variable_expense_this_year,
                                             fixed_expense_last_month, variable_expense_last_month, fixed_expense_last_year, variable_expense_last_year])
    end

    it 'returns from the current year when .this_year' do
      expect(described_class.this_year).to eq([income_this_year, fixed_expense_this_year, variable_expense_this_year,
                                               income_last_month, fixed_expense_last_month, variable_expense_last_month])
    end

    it 'returnsfrom the current month when .this_month' do
      expect(described_class.this_month).to eq([income_this_year, fixed_expense_this_year, variable_expense_this_year])
    end
  end
end

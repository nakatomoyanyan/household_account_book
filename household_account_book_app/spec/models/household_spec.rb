require 'rails_helper'

RSpec.describe Household, type: :model do
  subject { described_class.new(user:, category:) }

  let(:user) { FactoryBot.create(:user) }
  let(:category) { FactoryBot.build(:category, user:) }
  let(:income_record) { FactoryBot.create(:household, transaction_type: 0, user: user, name: 'Income', category: category) }
  let(:fixed_expense_record) { FactoryBot.create(:household, transaction_type: 1, user: user, name: 'Fixed Expense', category: category) }
  let(:variable_expense_record) { FactoryBot.create(:household, transaction_type: 2, user: user, name: 'Variable Expense', category: category) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      subject.name = 'food'
      subject.date = Time.zone.today
      subject.transaction_type = :income
      subject.amount = 1000
      expect(subject).to be_valid
    end

    it 'is not valid without a date' do
      subject.date = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a transaction type' do
      subject.transaction_type = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without an amount' do
      subject.amount = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid with a name longer than 20 characters' do
      subject.name = 'A' * 21
      expect(subject).not_to be_valid
    end
  end
  describe '.this_year' do
    let(:current_year_record) { FactoryBot.create(:household, date: Time.current, user: user, name: 'Current Year Record', category: category) }
    let(:last_year_record) { FactoryBot.create(:household, date: 1.year.ago, user: user, name: 'Last Year Record', category: category) }

    it 'returns records only from the current year' do
      expect(Household.this_year).to include(current_year_record)
      expect(Household.this_year).not_to include(last_year_record)
    end
  end
  describe '.this_month' do
    let(:current_month_record) { FactoryBot.create(:household, date: Time.current, user: user, name: 'Current Month Record', category: category) }
    let(:last_month_record) { FactoryBot.create(:household, date: 1.month.ago, user: user, name: 'Last Month Record', category: category) }

    it 'returns records only from the current month' do
      expect(Household.this_month).to include(current_month_record)
      expect(Household.this_month).not_to include(last_month_record)
    end
  end

  describe '.income' do
    it 'includes records with transaction_type 0 only' do
      expect(Household.income).to include(income_record)
      expect(Household.income).not_to include(fixed_expense_record)
      expect(Household.income).not_to include(variable_expense_record)
    end
  end
  describe '.expense' do
    it 'includes records with transaction_type 1 and 2 only' do
      expect(Household.expense).to include(fixed_expense_record, variable_expense_record)
      expect(Household.expense).not_to include(income_record)
    end
  end
end

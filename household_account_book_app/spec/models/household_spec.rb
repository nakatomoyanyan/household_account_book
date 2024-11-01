require 'rails_helper'

RSpec.describe Household, type: :model do
  subject { described_class.new(user:, category:) }

  let(:user) { FactoryBot.create(:user) }
  let(:category) { FactoryBot.build(:category, user:) }
  let(:income_record) do
    FactoryBot.create(:household, transaction_type: 0, user:, name: 'Income', category:)
  end
  let(:fixed_expense_record) do
    FactoryBot.create(:household, transaction_type: 1, user:, name: 'Fixed Expense', category:)
  end
  let(:variable_expense_record) do
    FactoryBot.create(:household, transaction_type: 2, user:, name: 'Variable Expense', category:)
  end

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
    let(:current_year_record) do
      FactoryBot.create(:household, date: Time.current, user:, name: 'Current Year Record', category:)
    end
    let(:last_year_record) do
      FactoryBot.create(:household, date: 1.year.ago, user:, name: 'Last Year Record', category:)
    end

    it 'returns records only from the current year' do
      expect(described_class.this_year).to include(current_year_record)
      expect(described_class.this_year).not_to include(last_year_record)
    end
  end

  describe '.this_month' do
    let(:current_month_record) do
      FactoryBot.create(:household, date: Time.current, user:, name: 'Current Month Record', category:)
    end
    let(:last_month_record) do
      FactoryBot.create(:household, date: 1.month.ago, user:, name: 'Last Month Record', category:)
    end

    it 'returns records only from the current month' do
      expect(described_class.this_month).to include(current_month_record)
      expect(described_class.this_month).not_to include(last_month_record)
    end
  end

  describe '.income' do
    it 'includes records with transaction_type 0 only' do
      expect(described_class.income).to include(income_record)
      expect(described_class.income).not_to include(fixed_expense_record)
      expect(described_class.income).not_to include(variable_expense_record)
    end
  end

  describe '.expense' do
    it 'includes records with transaction_type 1 and 2 only' do
      expect(described_class.expense).to include(fixed_expense_record, variable_expense_record)
      expect(described_class.expense).not_to include(income_record)
    end
  end
end

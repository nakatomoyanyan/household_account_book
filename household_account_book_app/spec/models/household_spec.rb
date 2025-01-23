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
    let(:expense) do
      create(:household, transaction_type: 1, date: Time.current, amount: 1000, user:,
                         category:)
    end

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

    context 'when the image is valid' do
      it 'allows uploading a JPEG file' do
        expense.images.attach(io: File.open('spec/fixtures/files/sample.jpeg'), filename: 'sample.jpeg',
                              content_type: 'image/jpeg')
        expect(expense).to be_valid
      end

      it 'allows uploading a PNG file' do
        expense.images.attach(io: File.open('spec/fixtures/files/sample.png'), filename: 'sample.png',
                              content_type: 'image/png')
        expect(expense).to be_valid
      end

      it 'allows uploading a PDF file' do
        expense.images.attach(io: File.open('spec/fixtures/files/sample.pdf'), filename: 'sample.pdf',
                              content_type: 'application/pdf')
        expect(expense).to be_valid
      end
    end

    context 'when the image is invalid' do
      it 'does not allow uploading a file larger than 5MB' do
        large_file = Tempfile.new(['large_file', '.jpeg'])
        large_file.write('a' * (5.megabytes + 1))
        large_file.rewind

        expense.images.attach(io: large_file, filename: 'large_file.jpeg', content_type: 'image/jpeg')
        expect(expense).not_to be_valid
      end

      it 'does not allow uploading a file with an unsupported format' do
        expense.images.attach(io: File.open('spec/fixtures/files/sample.txt'), filename: 'sample.txt',
                              content_type: 'text/plain')
        expect(expense).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    it 'returns the income when .income' do
      expect(described_class.income).to eq([income_this_year, income_last_month, income_last_year])
    end

    it 'returns the expense when .all_expense' do
      expect(described_class.all_expense).to eq([fixed_expense_this_year, variable_expense_this_year,
                                                 fixed_expense_last_month, variable_expense_last_month, fixed_expense_last_year, variable_expense_last_year])
    end

    it 'returns the expense when .fixed_expense' do
      expect(described_class.fixed_expense).to eq([fixed_expense_this_year, fixed_expense_last_month,
                                                   fixed_expense_last_year])
    end

    it 'returns the expense when .variable_expense' do
      expect(described_class.variable_expense).to eq([variable_expense_this_year, variable_expense_last_month,
                                                      variable_expense_last_year])
    end

    it 'returns from the current year when .this_year' do
      expect(described_class.this_year).to eq([income_this_year, fixed_expense_this_year, variable_expense_this_year])
    end

    it 'returns from the current month when .this_month' do
      expect(described_class.this_month).to eq([income_this_year, fixed_expense_this_year, variable_expense_this_year])
    end

    describe '.in_date_range' do
      let!(:record) do
        create(:household, transaction_type: 0, date: '2024-11-01', amount: 4000, user:, category:)
      end
      let!(:different_month_record) do
        create(:household, transaction_type: 0, date: '2024-12-01', amount: 4000, user:, category:)
      end

      it 'filters records within the specified month' do
        expect(described_class.in_date_range('2024-11')).to contain_exactly(record)
      end
    end

    describe '.filter_transaction_type' do
      let!(:income_record) do
        create(:household, transaction_type: 0, date: '2024-11-01', amount: 4000, user:, category:)
      end
      let!(:expense_record) do
        create(:household, transaction_type: 1, date: '2024-11-01', amount: 4000, user:, category:)
      end

      it 'filters income records' do
        expect(described_class.filter_transaction_type('income')).to contain_exactly(income_record)
      end

      it 'filters expense records' do
        expect(described_class.filter_transaction_type('expense')).to contain_exactly(expense_record)
      end
    end

    describe '.distinct_years_months' do
      let!(:record1) do
        create(:household, transaction_type: 0, date: Date.new(2024, 5, 10), amount: 4000, user:, category:)
      end
      let!(:record2) do
        create(:household, transaction_type: 1, date: Date.new(2024, 6, 10), amount: 4000, user:, category:)
      end
      let!(:record3) do
        create(:household, transaction_type: 1, date: Date.new(2024, 6, 10), amount: 4000, user:, category:)
      end
      let!(:record4) do
        create(:household, transaction_type: 0, date: Date.new(2023, 6, 10), amount: 4000, user:, category:)
      end

      it 'returns unique year and month combinations in descending order' do
        expected = [%w[2024 06], %w[2024 05], %w[2023 06]]
        expect(described_class.distinct_years_months).to eq(expected)
      end
    end
  end
end

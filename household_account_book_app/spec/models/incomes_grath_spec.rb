require 'rails_helper'

RSpec.describe IncomesGrath, type: :model do
  let(:user) { create(:user) }
  let(:incomes_grath) { build(:incomes_grath, user:) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      incomes_grath.grath_data_this_month = { youtube: 77_964, 'アルバイト': 146_489, 'メルカリ': 125_002, '物販': 114_115,
                                              '給料': 99_898 }
      incomes_grath.grath_data_this_year = { '1月': 569_967, '2月': 562_950, '3月': 549_656, '4月': 514_929, '5月': 506_945, '6月': 580_210,
                                             '7月': 550_780, '8月': 575_293, '9月': 542_013, '10月': 511_263, '11月': 513_511, '12月': 563_468 }
      expect(incomes_grath).to be_valid
    end

    it 'is not valid without a grath_data_this_month' do
      incomes_grath.grath_data_this_month = nil
      expect(incomes_grath).not_to be_valid
    end

    it 'is not valid without a grath_data_this_year' do
      incomes_grath.grath_data_this_year = nil
      expect(incomes_grath).not_to be_valid
    end
  end
end

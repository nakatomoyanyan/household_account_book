require 'rails_helper'

RSpec.describe IncomesGraphDataJob, type: :job do
  let!(:user) { create(:user) }
  let!(:category) { create(:category, user:, name: '給料') }
  let!(:household) do
    create(:household, user:, category:, transaction_type: :income, amount: 100_000, date: Date.current)
  end

  describe '#perform' do
    it 'confirms that the correct data is created' do
      described_class.perform_now(user.id)
      expect(IncomesGraph.count).to eq 1

      graph_data = IncomesGraph.last
      expected_graph_data_this_month = { category.name => household.amount }
      expected_graph_data_this_year = { Time.zone.today.strftime('%-m月') => household.amount }

      expect(graph_data.graph_data_this_month).to eq(expected_graph_data_this_month)
      expect(graph_data.graph_data_this_year).to eq(expected_graph_data_this_year)
    end
  end
end

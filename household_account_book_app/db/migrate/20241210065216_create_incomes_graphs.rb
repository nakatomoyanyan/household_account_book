class CreateIncomesGraphs < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes_graphs do |t|
      t.references :user, null: false, foreign_key: true 
      t.json :graph_data_this_month
      t.json :graph_data_this_year

      t.timestamps
    end
  end
end

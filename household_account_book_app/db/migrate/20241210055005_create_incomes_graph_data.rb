class CreateIncomesGraphData < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes_graph_data do |t|
      t.references :household, null: false, foreign_key: true
      t.string :category_name
      t.integer :total_amount

      t.timestamps
    end
  end
end

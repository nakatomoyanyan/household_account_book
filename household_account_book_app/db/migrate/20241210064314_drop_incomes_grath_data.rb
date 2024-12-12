class DropIncomesGrathData < ActiveRecord::Migration[7.2]
  def change
    drop_table :incomes_graph_data
  end
end

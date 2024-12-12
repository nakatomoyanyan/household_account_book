class CreateIncomesGraths < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes_graths do |t|
      t.references :user, null: false, foreign_key: true 
      t.json :grath_data_this_month
      t.json :grath_data_this_year

      t.timestamps
    end
  end
end

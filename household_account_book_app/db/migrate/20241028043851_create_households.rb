class CreateHouseholds < ActiveRecord::Migration[7.2]
  def change
    create_table :households do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.string :name
      t.integer :transaction_type
      t.references :category, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end

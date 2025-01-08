class AddIncomesLastCheckedAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :incomes_last_checked_at, :datetime, default: '2025-01-01 00:00:00'
  end
end

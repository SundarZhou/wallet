class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.integer :source_id, null: false
      t.integer :destination_id, null: true
      t.integer :transaction_type, null: false
      t.decimal :amount, :precision => 8, :scale => 2, default: 0.00, null: false
      t.string  :message
      t.string  :transaction_token

      t.timestamps
    end
  end
end

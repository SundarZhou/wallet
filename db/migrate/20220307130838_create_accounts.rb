class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest
      t.string :address, null: false
      t.decimal :balance, :precision => 8, :scale => 2, default: 0.00, null: false
      t.integer :operation_record, default: 0, null: false

      t.timestamps
    end
  end
end

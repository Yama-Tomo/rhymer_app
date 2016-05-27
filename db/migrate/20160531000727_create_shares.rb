class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :hash_id, null:false
      t.text :content, null: false, default: ''

      t.timestamps
    end
    add_index :shares, [:hash_id], :unique => true, :name => 'shares_idx01'
  end
end

class CreateOrder < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :shopify_id, limit: 8, index: {unique: true}

      t.timestamps
    end
  end
end

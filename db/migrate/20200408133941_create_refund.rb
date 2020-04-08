class CreateRefund < ActiveRecord::Migration[5.0]
  def change
    create_table :refunds do |t|
      t.integer :shopify_id, limit: 8, index: {unique: true}
    end
  end
end

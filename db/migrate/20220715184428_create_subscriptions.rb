class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :stripe_id
      t.string :stripe_price_id
      t.string :stripe_product_name
      t.string :status
      t.string :quantity

      t.timestamps
    end
  end
end

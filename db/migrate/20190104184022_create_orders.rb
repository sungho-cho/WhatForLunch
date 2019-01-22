class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :restaurant, foreign_key: true
      t.datetime :date
      t.decimal :user_latitude
      t.decimal :user_longitude

      t.timestamps
    end
  end
end

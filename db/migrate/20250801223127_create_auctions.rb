class CreateAuctions < ActiveRecord::Migration[8.0]
  def change
    create_table :auctions do |t|
      t.references :rfq, null: false, foreign_key: true
      t.string :status
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :current_price

      t.timestamps
    end
  end
end

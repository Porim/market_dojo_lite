class CreateEmailPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :email_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :rfq_created
      t.boolean :quote_received
      t.boolean :auction_started
      t.boolean :auction_ended
      t.boolean :quote_accepted

      t.timestamps
    end
  end
end

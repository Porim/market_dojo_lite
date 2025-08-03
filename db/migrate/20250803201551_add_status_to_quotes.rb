class AddStatusToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :status, :string
  end
end

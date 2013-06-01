class AddUuidToSpime < ActiveRecord::Migration
  def change
    add_column :spimes, :uuid, :string
  end
end

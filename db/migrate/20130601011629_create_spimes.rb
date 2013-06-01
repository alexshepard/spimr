class CreateSpimes < ActiveRecord::Migration
  def change
    create_table :spimes do |t|
      t.string :name, :null => false
      t.text :description, :null => false
      t.string :image, :null => false
      t.boolean :public, :null => false
      t.text :materials, :null => false
      t.timestamp :date_manufactured, :null => false

      t.timestamps
    end
  end
end

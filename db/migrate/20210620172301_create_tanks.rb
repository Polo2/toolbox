class CreateTanks < ActiveRecord::Migration[6.1]
  def change
    create_table :tanks do |t|
      t.integer :distance
      t.float :volume
      t.float :price
      t.boolean :full
      t.datetime :date

      t.timestamps
    end
  end
end

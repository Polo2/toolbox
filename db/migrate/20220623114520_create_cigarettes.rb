class CreateCigarettes < ActiveRecord::Migration[6.1]
  def change
    create_table :cigarettes do |t|
      t.integer :quantity
      t.datetime :date

      t.timestamps
    end
  end
end

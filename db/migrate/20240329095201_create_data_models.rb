class CreateDataModels < ActiveRecord::Migration[7.1]
  def change
    create_table :data_models do |t|
      t.string :name
      t.text :data

      t.timestamps
    end
  end
end

class CreateExternalServices < ActiveRecord::Migration[5.1]
  def change
    create_table :external_services do |t|
      t.string :draft_doi
      t.string :work_id
      t.jsonb :property, default: '[ ]'
      t.timestamps
    end
    add_index :external_services, :draft_doi, unique: true
  end
end

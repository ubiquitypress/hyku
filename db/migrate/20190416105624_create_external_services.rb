class CreateExternalServices < ActiveRecord::Migration[5.1]
  def change
    create_table :external_services do |t|
      t.string :draft_doi
      t.string :work_id
      t.jsonb :property, default: '[ ]'
      t.jsonb  :data, default: {}, null: false
      t.timestamps
    end
    add_index :external_services, [:draft_doi, :work_id], unique: true, where: "draft_doi IS NOT NULL"
    add_index :external_services, :data, using: 'gin',  where: "(data -> 'api_type') is not null"
    add_index :external_services, :property, using: 'gin'

  end
end

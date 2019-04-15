class CreateUbiquityExternalServices < ActiveRecord::Migration[5.1]
  def change
    create_table :ubiquity_external_services do |t|
      t.string :draft_doi
      t.string :work_id
      t.references :account, foreign_key: {to_table: 'public.accounts'} #true
      t.jsonb :property, default: '[ ]'

      t.timestamps
    end
    add_index :ubiquity_external_services,  [:draft_doi, :account_id], unique: true
  end
end

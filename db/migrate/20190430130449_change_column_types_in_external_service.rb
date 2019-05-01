class ChangeColumnTypesInExternalService < ActiveRecord::Migration[5.1]
  def up
    change_column :external_services, :property, :jsonb, default: []
    change_column :external_services, :data, :jsonb, default: {}, null: true
  end

  def down
    change_column :external_services, :property, :jsonb, default: '[ ]'
    change_column :external_services, :data, :jsonb, default: {}
  end
end

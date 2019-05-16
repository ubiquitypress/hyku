class AddParentIdAndDataSettingsColumnToAccount < ActiveRecord::Migration[5.1]
  def change
    add_reference :accounts, :parent, foreign_key: { to_table: :accounts }
    add_column :accounts, :settings, :jsonb, default: {}
    add_column :accounts, :data, :jsonb, default: {}
  end
end

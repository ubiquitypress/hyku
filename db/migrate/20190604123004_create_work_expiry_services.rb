class CreateWorkExpiryServices < ActiveRecord::Migration[5.1]
  def change
    create_table :work_expiry_services do |t|
      t.string :work_id
      t.string :work_type
      t.string :tenant_name
      t.datetime :expiry_time
      t.jsonb :data, default: {}

      t.timestamps
    end
    add_index :work_expiry_services, [:work_id, :work_type]
  end
end

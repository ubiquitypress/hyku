class ChangeUbiquityExternalServicesToExternalServices < ActiveRecord::Migration[5.1]
  def change
    rename_table :ubiquity_external_services, :external_services
  end
end

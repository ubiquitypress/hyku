
#run with rake hyku:automatic_user:create['sandbox.repo-test.ubiquity.press']

namespace :hyku do
  namespace :automatic_user do
    desc "Create a user and make that user a superadmin"
    task :create => :environment do 
    #task :create, [:tenant_name] => :environment do |task, tenant|
      #AccountElevator.switch!("#{tenant[:tenant_name]}")

      email = "tech_#{rand(252...41350)}@ubiquity.press.com"
      puts "Creating user with email #{email}"
      User.find_or_create_by(email: email) do |user|
         puts "assigning password to user"
         user.password = 'ubiquity2197';
         user.password_confirmation = 'ubiquity2197'
         puts "Granting user superadmin role"
         user.add_role(:superadmin)
     end

     puts "User successfully created"
    end

  end
end

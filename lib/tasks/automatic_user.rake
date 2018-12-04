
#run with:
#bundle exec rake hyku:automatic_user:create

namespace :hyku do
  namespace :automatic_user do
    desc "Create a user and make that user a superadmin"
    task :create => :environment do

      email = ENV['DEFAULT_ADMIN_EMAIL']
      password = ENV['DEFAULT_ADMIN_PASSWORD']
      puts "Creating user with email #{email}"
    
      User.create! do |user|
         puts "assigning password to user"
         user.email = email
         user.password = password;
         user.password_confirmation = password
         puts "Granting user superadmin role"
         user.add_role(:superadmin)
     end

     puts "User successfully created"
    end

  end
end

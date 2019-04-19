FactoryGirl.define do
  factory :upload_file, class: Hyrax::UploadedFile do |factory|
    factory.file { Rails.root.join('spec', 'fixtures', 'images', 'world.png') }
  end
end

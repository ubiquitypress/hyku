RSpec.describe Hyrax::UploadsController do
  let(:user) { FactoryGirl.create(:base_user) }
  let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'images', 'world.png')) }

  # let(:file_upload) { FactoryGirl.create(:upload_file) }

  context "File is uploaded from the edit page of the work and attach the file" do
    before do
      sign_in(user)
    end

    describe 'POST create method in Uploads Controller' do
      it 'assigns @upload' do
        # post :create, params: { files: [file: file] }
        # expect(assigns(:upload)).to eq([file_upload])
      end
    end
  end
end

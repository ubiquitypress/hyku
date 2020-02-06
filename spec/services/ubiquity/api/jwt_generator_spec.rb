RSpec.describe Ubiquity::Api::JwtGenerator do
  let!(:user) { create(:user) }

  describe "encode" do
    it "encodes a payload successfully" do
       payload = {id: user.id}
       token = subject.class.encode(payload)
       expect(token).to be_truthy
    end
  end

  describe "decode" do
    it "decodes a payload successfully" do
       payload = {id: user.id}
       token = subject.class.encode(payload)
       decode = subject.class.decode(token)
       expect(decode['id']).to eq(payload[:id])
    end
  end

end

RSpec.describe Ubiquity::FetchTenantUrl do

  it 'changes the cname to the live setting if the cname is in the env' do
    account = FactoryGirl.create(:account, cname: "live")
    work = GenericWork.new("account_cname": account.cname)
    f = Ubiquity::FetchTenantUrl.new(work)
    expect { f.process_url }.to change { f.instance_variable_get(:@account_cname) }.from("live").to("commons.pacificu.edu")
  end

  it "doesn't change the cname if the cname is not in the env" do
    account = FactoryGirl.create(:account, cname: "testymctestface")
    work = GenericWork.new("account_cname": account.cname)
    f = Ubiquity::FetchTenantUrl.new(work)
    expect { f.process_url }.to_not change { f.instance_variable_get(:@account_cname) }
  end

  it 'generates a new URL with the live cname' do
    account = FactoryGirl.create(:account, cname: "live")
    work = GenericWork.new("account_cname": account.cname)
    f = Ubiquity::FetchTenantUrl.new(work)
    expect(f.process_url).to include("commons.pacificu.edu")
  end
end

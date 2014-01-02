require 'spec_helper'

describe "waiting_lists/show" do
  before(:each) do
    @waiting_list = assign(:waiting_list, stub_model(WaitingList,
      :email => "Email",
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Email/)
    rendered.should match(/Name/)
  end
end

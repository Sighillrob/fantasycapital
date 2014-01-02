require 'spec_helper'

describe "waiting_lists/index" do
  before(:each) do
    assign(:waiting_lists, [
      stub_model(WaitingList,
        :email => "Email",
        :name => "Name"
      ),
      stub_model(WaitingList,
        :email => "Email",
        :name => "Name"
      )
    ])
  end

  it "renders a list of waiting_lists" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end

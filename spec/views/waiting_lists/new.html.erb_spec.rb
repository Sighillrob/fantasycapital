require 'spec_helper'

describe "waiting_lists/new" do
  before(:each) do
    assign(:waiting_list, stub_model(WaitingList,
      :email => "MyString",
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new waiting_list form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", waiting_lists_path, "post" do
      assert_select "input#waiting_list_email[name=?]", "waiting_list[email]"
      assert_select "input#waiting_list_name[name=?]", "waiting_list[name]"
    end
  end
end

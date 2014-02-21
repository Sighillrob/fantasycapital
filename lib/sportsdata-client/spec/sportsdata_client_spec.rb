require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SportsdataClient" do
  it "should retry when getting 5xx" do
    client = SportsdataClient::Client.new ""
    response = double()
    response.stub(:code).and_return(501)
    client.class.stub(:get).and_return(response)
    client.stub(:max_retries).and_return(3)
    client.stub(:interval).and_return(0)
    client.request("", {})
  end
end

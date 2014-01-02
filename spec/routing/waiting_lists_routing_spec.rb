require "spec_helper"

describe WaitingListsController do
  describe "routing" do

    it "routes to #index" do
      get("/waiting_lists").should route_to("waiting_lists#index")
    end

    it "routes to #new" do
      get("/waiting_lists/new").should route_to("waiting_lists#new")
    end

    it "routes to #show" do
      get("/waiting_lists/1").should route_to("waiting_lists#show", :id => "1")
    end

    it "routes to #edit" do
      get("/waiting_lists/1/edit").should route_to("waiting_lists#edit", :id => "1")
    end

    it "routes to #create" do
      post("/waiting_lists").should route_to("waiting_lists#create")
    end

    it "routes to #update" do
      put("/waiting_lists/1").should route_to("waiting_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/waiting_lists/1").should route_to("waiting_lists#destroy", :id => "1")
    end

  end
end

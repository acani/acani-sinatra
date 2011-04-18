require 'spec_helper'

describe User do
  let(:user) do
    User.new.tap { |u| u.device_id = "123" }    
  end

  it "has the expected attributes" do
    user.should respond_to(
      :id, :id=, :_id, :_id=,
      :device_id, :device_id=
    )
  end

  it "initializes with a hash" do
    bson_object_id = BSON::ObjectId('4dac7cbf1467283e9d000001')

    user = User.new({
      _id: bson_object_id,
      device_id: "123"
    })

    user.id.should equal(bson_object_id)
    user.device_id.should eq("123")
  end

  it "sets & gets a device_id" do
    user.device_id = "456"
    user.device_id.should eq("456")
  end

  it "saves to database" do
    user.save
    users = DB.collection("users")
    users.find.to_a.should have(1).user
  end
    
  it "finds by device id" do
    user.save
    found_user = User.find_by_device_id(user.device_id)
    found_user.device_id.should eq(user.device_id)
  end
end

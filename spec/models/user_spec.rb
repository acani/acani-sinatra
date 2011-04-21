require 'spec_helper'

describe User do
  let(:user) do
    User.new.tap { |u| u.devices = ["123", "456"] }    
  end

  it "has the expected attributes" do
    user.should respond_to(
      :id, :id=, :_id, :_id=,
      :devices, :devices=
    )
  end

  it "initializes with a hash" do
    bson_object_id = BSON::ObjectId('4dac7cbf1467283e9d000001')

    user = User.new({
      _id: bson_object_id,
      devices: ["123"]
    })

    user.id.should equal(bson_object_id)
    user.devices.should eq(["123"])
  end

  it "sets & gets a device_id" do
    user.devices = ["456"]
    user.devices.should eq(["456"])
  end

  it "saves to database" do
    user.save
    user.id.should_not be_nil
    USERS.find.to_a.should have(1).user
  end

  describe "::find_by_device_id" do
    it "misses" do
      found_user = User.find_by_device_id("123")
      found_user.should be_nil
    end

    it "finds" do
      user.save
      found_user = User.find_by_device_id("456")
      found_user.should_not be_nil
      found_user.id.should eq(user.id)
      found_user.devices.should eq(user.devices)
    end
  end
end

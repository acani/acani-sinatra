class User
  attr_accessor :id, :device_id, :updated_date
  alias_method(:_id, :id); alias_method(:_id=, :id=)
    
  def initialize(options={})
    options.each_pair do |k, v|
      self.send("#{k.to_sym}=", v)
    end
  end

  def self.find_by_device_id(device_id)
    users = DB.collection("users")
    user_bson = users.find({device_id: device_id}, {limit: 1}).first
    User.new(user_bson) unless user_bson.nil?
  end

  def save
    users = DB.collection("users")
    users.insert({device_id: device_id})
  end
end

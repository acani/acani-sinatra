class User
  attr_accessor :id, :devices # , :updated_date
  alias_method(:_id, :id); alias_method(:_id=, :id=)
  alias_method(:c, :devices); alias_method(:c=, :devices=)
  
  def initialize(options={})
    options.each_pair do |k, v|
      self.send("#{k.to_sym}=", v)
    end
  end

  def self.find_by_device_id(device_id)
    user_bson = USERS.find({USR[:devices] => device_id}, {limit: 1}).first
    unless user_bson.nil?
      user_hash = {id: user_bson["_id"], devices: user_bson["c"]}
      User.new(user_hash)
    end
  end

  def save
    if self.id.nil?
      self.id = USERS.insert({USR[:devices] => devices})
    else
      update
    end
  end

  def update
    USERS.update({_id: self.id}, "$set" => {USR[:devices] => devices})
  end
end

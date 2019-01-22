class Group < ApplicationRecord
  attr_encrypted_options.merge!(key: ENV.fetch('ATTR_ENCRYPTED_SECRET'))
  attr_encrypted :mailchimp_api_key
end

Group.create!(name:"YELP", mailchimp_api_key: "3aDdsPDW2m895TsuSyzsZbEq17XAZcXiQjB55eCWAqfgcwHZeR_kcf0EyhHOfILUCXlN8adub_XNRAOhqQNvfeG8_sNrz4t6NuxM6LSAbvx4rHlH4JLDXWtQHPgXXHYx")
Group.create!(name:"GOOGLE MAPS", mailchimp_api_key: "AIzaSyCvX58lj15YFsVDfzUqzqc1ayZeBPmArmw")

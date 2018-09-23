require 'active_model'

class User
  include ActiveModel::Model

  attr_accessor :can_create_article
end

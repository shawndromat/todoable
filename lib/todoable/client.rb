require 'rest-client'
require 'json'

require 'todoable/api/lists'
require 'todoable/api/items'

module Todoable
  class Client
    include API::Lists
    include API::Items

    def initialize(user:, password:)
      @user = user
      @password = password
    end
  end
end

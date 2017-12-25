require 'rest-client'
require 'json'

require 'todoable/api/lists'

module Todoable
  class Client
    include API::Lists

    def initialize(user:, password:)
      @user = user
      @password = password
    end
  end
end

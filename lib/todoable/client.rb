require 'rest-client'
require 'json'

module Todoable
  class Client
    URL = 'http://todoable.teachable.tech/api'

    def initialize(user:, password:)
      @user = user
      @password = password
    end

    def lists
      request('/lists', :get)['lists']
    end

    private

    def token
      @token ||= get_token
    end

    def request(path, method, payload = nil)
      begin
        tries ||= 0
        response = RestClient::Request.execute(
          url: URL + path,
          method: method,
          payload: payload,
          headers: {
            authorization: "Token token=\"#{token}\"",
            accept: :json,
            content_type: :json
          }
        )

        JSON.parse(response)
      rescue RestClient::Exception => error
        if tries == 0
          @token = get_token
          retry
        else
          raise_unauthorized(error)
        end
      end
    end

    def get_token
      begin
        response = RestClient::Request.execute(
          url: URL + '/authenticate',
          method: :post,
          user: @user,
          password: @password
        )
        JSON.parse(response)['token']
      rescue RestClient::Exception => error
        raise_unauthorized(error)
      end
    end

    def raise_unauthorized(error)
      if error.http_code == 401
        raise 'Bad authentication data'
      end
    end
  end
end

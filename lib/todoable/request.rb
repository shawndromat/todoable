require 'todoable/error'

module Todoable
  module Request
    URL = 'http://todoable.teachable.tech/api'

    protected

    def token
      @token ||= get_token
    end

    def json_request(path, method, payload = nil)
      JSON.parse(request(path, method, payload))
    end

    def request(path, method, payload = nil)
      begin
        tries ||= 0
        RestClient::Request.execute(
          url: URL + path,
          method: method,
          payload: payload,
          headers: {
            authorization: "Token token=\"#{token}\"",
            accept: :json,
            content_type: :json
          }
        )
      rescue RestClient::UnprocessableEntity => error
        raise_unprocessable(error)
      rescue RestClient::Unauthorized => error
        if tries == 0
          tries += 1
          @token = get_token
          retry
        else
          raise_unauthorized(error)
        end
      rescue RestClient::NotFound
        raise Todoable::Error, 'Resource not found'
      rescue RestClient::UnprocessableEntity => error
        raise_unprocessable(error)
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
        raise Todoable::Error, 'Bad authentication data'
      end
    end

    def raise_unprocessable(error)
      message = JSON.parse(error.http_body).map do |attribute, messages|
        messages.map {|message| "#{attribute} #{message}"}.join(', ')
      end.join(', ')

      raise Todoable::Error, message
    end
  end
end

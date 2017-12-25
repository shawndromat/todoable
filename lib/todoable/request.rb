require 'todoable/error'

module Todoable
  module Request
    URL = 'http://todoable.teachable.tech/api'

    protected

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

    def raise_unprocessable(error)
      message = JSON.parse(error.http_body).map do |attribute, messages|
        messages.map {|message| "#{attribute} #{message}"}.join(', ')
      end.join(', ')

      raise Todoable::Error, message
    end
  end
end

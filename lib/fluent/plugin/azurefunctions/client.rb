module AzureFunctions
  class HTTPTriggerClient
    def initialize (endpoint, function_key)
      require 'rest-client'
      require 'json'
      @endpoint = endpoint
      @function_key = function_key
      @headers = {
        'Content-Type' => "application/json; charset=UTF-8"
      }
    end 

    def post(payload)
      raise ConfigError, 'no payload' if payload.empty?
      res = RestClient.post(
              "#{@endpoint}?code=#{@function_key}",
              { :payload => payload }.to_json,
              @headers)
      res
    end
  end
end

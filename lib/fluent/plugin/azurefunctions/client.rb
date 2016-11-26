module AzureFunctions
  class HTTPTriggerClient
    def initialize (endpoint, function_key)
      require 'rest-client'
      require 'json'
      @endpoint = endpoint
      @headers = {
        'Content-Type' => "application/json; charset=UTF-8",
        'x-functions-key' => function_key
      }
    end 

    def post(payload)
      raise ConfigError, 'no payload' if payload.empty?
      res = RestClient.post(
              @endpoint,
              { :payload => payload }.to_json,
              @headers)
      res
    end
  end
end



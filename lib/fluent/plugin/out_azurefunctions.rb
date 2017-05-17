# -*- coding: utf-8 -*-

require 'fluent/plugin/output'

module Fluent::Plugin
  class AzureFunctionsOutput < Output
    Fluent::Plugin.register_output('azurefunctions', self)

    helpers :compat_parameters

    DEFAULT_BUFFER_TYPE = "memory"

    def initialize
      super
      require 'msgpack'
      require 'time'
      require 'fluent/plugin/azurefunctions/client'
    end

    config_param :endpoint, :string,
                 :desc => "Azure Functions Endpoint URL"
    config_param :function_key, :string, :secret => true,
                 :desc => "Azure Functions API key"
    config_param :key_names, :string, default: nil,
                 :desc => "Key names in in-comming records to post to Azure functions HTTP Trigger functions. Each key needs to be separated by a comma. If key_names not specified, all in-comming records are posted. If in-comming records contain the same key names as the ones specified in time_field_name and tag_field_name, their values are replaced by the values of time_field_name and tag_field_name."
    config_param :add_time_field, :bool, :default => true,
                 :desc => "This option allows to insert a time field to record"
    config_param :time_field_name, :string, :default => "time",
                 :desc => "This is required only when add_time_field is true"
    config_param :time_format, :string, :default => "%s",
                 :desc => "Time format for a time field to be inserted. Default format is %s, that is unix epoch time. If you want it to be more human readable, set this %Y%m%d-%H:%M:%S, for example. This is valid only when add_time_field is true."
    config_param :localtime, :bool, :default => false,
                 :desc => "Time record is inserted with UTC (Coordinated Universal Time) by default. This option allows to use local time if you set localtime true. This is valid only when add_time_field is true."
    config_param :add_tag_field, :bool, :default => false,
                 :desc => "This option allows to insert a tag field to record"
    config_param :tag_field_name, :string, :default => "tag",
                 :desc => "This is required only when add_time_field is true"

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
      raise Fluent::ConfigError, 'no endpoint' if @endpoint.empty?
      raise Fluent::ConfigError, 'no function_key' if @function_key.empty?
      if not @key_names.nil?
        @key_names = @key_names.split(',')
      end
      if @add_time_field and @time_field_name.empty?
        raise Fluent::ConfigError, 'time_field_name must be set if add_time_field is true'
      end
      if @add_tag_field and @tag_field_name.empty?
        raise Fluent::ConfigError, 'tag_field_name must be set if add_tag_field is true'
      end
      @timef = Fluent::TimeFormatter.new(@time_format, @localtime)
    end

    def start
      super
      # start
      @client=AzureFunctions::HTTPTriggerClient::new(@endpoint,@function_key)
    end

    def shutdown
      super
      # destroy
    end

    def format(tag, time, record)
      if @add_time_field
        record[@time_field_name] = @timef.format(time)
      end
      if @add_tag_field
        record[@tag_field_name] = tag
      end

      r = {}
      r['.rid'] =  SecureRandom.uuid
      if @add_time_field
        r[@time_field_name] = @timef.format(time)
      end
      if @add_tag_field
        r[@tag_field_name] = tag
      end

      if not @key_names.nil?
        @key_names.each_with_index do |key, i|
          value = record.include?(key) ? record[key] : ''
          r[key] = value
        end
        record = r
      else
        record = record.merge(r)
      end
      record.to_msgpack
    end

    def formatted_to_msgpack_binary?
      true
    end

    def multi_workers_ready?
      true
    end

    def write(chunk)
      chunk.msgpack_each { |record|
        payload = JSON.dump(record)
        unique_identifier = record[".rid"]
        #p "payload=#{payload}"
        #p "unique_identifier=#{unique_identifier}"
        begin
          @client.post(payload)
        rescue Exception => ex
          log.fatal "Error occured in posting to Azure Functions HTTP trigger function: "
                  + "'#{ex}', .rid=>#{unique_identifier}, payload=>" + payload
        end
      }
    end
  end
end

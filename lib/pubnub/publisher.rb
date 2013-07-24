require "net/https"
require "net/http"
require "uri"
require "json"
require "securerandom"
require "pubnub/publisher/version"

module Pubnub
  class Publisher

    CONFIG_KEYS = [:publish_key, :subscribe_key, :secret_key, :cipher_key, :ssl, :origin, :session_uuid]
    REQUIRED_KEYS = [:publish_key, :subscribe_key, :origin]
    DEFAULT_ORIGIN = "pubsub.pubnub.com"
    attr_accessor *CONFIG_KEYS

    class ConfigNotSet < StandardError; end

    # sets up the class so instances can inherit from the default config.
    #
    # @param opts [hash] keyed by symbols, stores the connection config that is 
    # then used by default by all instances.
    def self.setup(opts={})
      @publish_key = opts[:publish_key] if opts[:publish_key]
      @subscribe_key = opts[:subscribe_key] if opts[:subscribe_key]
      @secret_key = opts[:secret_key] if opts[:secret_key]
      @cipher_key = opts[:cipher_key] if opts[:cipher_key]
      @origin = opts[:origin] || DEFAULT_ORIGIN
      @session_uuid = opts[:session_uuid] || SecureRandom.uuid
      @ssl = opts[:ssl].nil? ? true : opts[:ssl]
    end

    # resets the shared config
    def self.clear
      @publish_key, @subscribe_key, @secret_key, @cipher_key, @origin, @session_uuid, @ssl = nil, nil, nil, nil, "pubsub.pubnub.com", nil, true
    end

    def self.set_default_values(instance)
      instance.publish_key ||= @publish_key if @publish_key
      instance.subscribe_key ||= @subscribe_key if @subscribe_key
      instance.secret_key ||= @secret_key if @secret_key
      instance.cipher_key ||= @cipher_key if @cipher_key
      instance.origin ||= (@origin || DEFAULT_ORIGIN)
      instance.session_uuid ||= (@session_uuid || SecureRandom.uuid)
      if instance.ssl.nil?
        instance.ssl = !@ssl.nil? ? @ssl : true
      end
      instance
    end

    def self.publish_key; @publish_key end
    def self.subscribe_key; @subscribe_key end
    def self.ssl; @ssl end

    def initialize(opts={})
      opts.each do |k,v|
        next unless CONFIG_KEYS.include?(k)
        self.send("#{k}=", v)
      end
      # load the default values
      self.class.set_default_values(self)
      self
    end

    def publish(channel, message)
      check_config
      http, request = prepare_message_publishing(channel, message)
      response = http.request(request)
      if response.code == "200"
        # check response
        # [1 good!
        # [0 bad!
        if response.body =~ /\[1,/
          true
        else
          $stderr << response.body[/\[\d,"(.*)"/]
          false
        end
      else
        $stderr << response.inspect
        false
      end
    end

    def check_config
      if @config_ok
        true
      else
        REQUIRED_KEYS.each do |k|
          value = self.send(k)
          raise ConfigNotSet.new("#{k} not set") if value.nil? || value == ""
        end
        @config_ok = true
      end
    end

    #http://pubsub.pubnub.com
    # /publish
    # /pub-key
    # /sub-key
    # /signature
    # /channel
    # /callback
    def publish_url(channel)
      (ssl ? "https" : "http") << "://#{origin}/publish/#{publish_key}/#{subscribe_key}/#{secret_key || 0}/#{channel}/0"
    end

    def prepare_message_publishing(channel, message)
      raise ArgumentError if (channel.nil? || channel == "" || message.nil? || message == "")

      # prepare a GET request (come on pubnub, GET???)
      url =  publish_url(channel) << "/#{URI.escape(message.to_json)}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      # gonna have to deal with certs
      if ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      return http, request
    end

  end
end

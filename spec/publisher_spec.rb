require 'spec_helper'

describe Pubnub::Publisher do
  context "Class setup" do

    it "has default values" do
      pub_client = Pubnub::Publisher.new
      expect(pub_client.publish_key).to be_nil
      expect(pub_client.subscribe_key).to be_nil
      expect(pub_client.secret_key).to be_nil
      expect(pub_client.cipher_key).to be_nil
      expect(pub_client.origin).to eq("pubsub.pubnub.com")
      expect(pub_client.session_uuid).to_not be_empty
      expect(pub_client.ssl).to be_true
    end

    it "allows a dev to set some shared config options" do
      Pubnub::Publisher.setup(publish_key: "test pub key")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.publish_key).to eq("test pub key")

      Pubnub::Publisher.setup(subscribe_key: "test sub key")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.subscribe_key).to eq("test sub key")

      Pubnub::Publisher.setup(secret_key: "test secret key")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.secret_key).to eq("test secret key")

      Pubnub::Publisher.setup(cipher_key: "test cipher key")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.cipher_key).to eq("test cipher key")

      Pubnub::Publisher.setup(origin: "matt.pubnub.com")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.origin).to eq("matt.pubnub.com")

      Pubnub::Publisher.setup(session_uuid: "test-runner")
      pub_client = Pubnub::Publisher.new
      expect(pub_client.session_uuid).to eq("test-runner")

      Pubnub::Publisher.setup(ssl: false)
      pub_client = Pubnub::Publisher.new
      expect(pub_client.ssl).to be_false
    end

    it "can be cleared" do
      Pubnub::Publisher.clear
      pub_client = Pubnub::Publisher.new
      expect(pub_client.publish_key).to be_nil
      expect(pub_client.subscribe_key).to be_nil
      expect(pub_client.secret_key).to be_nil
      expect(pub_client.cipher_key).to be_nil
      expect(pub_client.origin).to eq("pubsub.pubnub.com")
      expect(pub_client.session_uuid).to_not be_empty
      expect(pub_client.ssl).to be_true
    end

    it "has some global getters" do
      Pubnub::Publisher.setup(publish_key: "pub key", subscribe_key: "sub key", ssl: false)
      expect(Pubnub::Publisher.publish_key).to eql("pub key")
      expect(Pubnub::Publisher.subscribe_key).to eql("sub key")
    end

  end

  context "new instance" do
    before :each do
      Pubnub::Publisher.clear
    end

    it "can have custom config values" do
      pub_client = Pubnub::Publisher.new(publish_key: "test pub key")
      expect(pub_client.publish_key).to eq("test pub key")

      pub_client = Pubnub::Publisher.new(subscribe_key: "test sub key")
      expect(pub_client.subscribe_key).to eq("test sub key")

      pub_client = Pubnub::Publisher.new(secret_key: "test secret key")
      expect(pub_client.secret_key).to eq("test secret key")

      pub_client = Pubnub::Publisher.new(cipher_key: "test cipher key")
      expect(pub_client.cipher_key).to eq("test cipher key")

      pub_client = Pubnub::Publisher.new(origin: "matt.pubnub.com")
      expect(pub_client.origin).to eq("matt.pubnub.com")

      pub_client = Pubnub::Publisher.new(session_uuid: "test-instance-runner")
      expect(pub_client.session_uuid).to eq("test-instance-runner")

      pub_client = Pubnub::Publisher.new(ssl: false)
      expect(pub_client.ssl).to be_false
    end

    it "can be verified (check that required fields are set)" do
      pub_client = Pubnub::Publisher.new
      expect(pub_client.publish_key).to be_nil
      expect{ pub_client.check_config }.to raise_error(Pubnub::Publisher::ConfigNotSet)

      valid_config = {publish_key: "test", subscribe_key: "test", origin: "test.pubnub.com"}
      expect{ Pubnub::Publisher.new(valid_config).check_config }.to_not raise_error(Pubnub::Publisher::ConfigNotSet)
      without_pub_key = valid_config.dup
      without_pub_key.delete(:publish_key)
      expect{ Pubnub::Publisher.new(without_pub_key).check_config }.to raise_error(Pubnub::Publisher::ConfigNotSet)
      without_sub_key = valid_config.dup
      without_sub_key.delete(:subscribe_key)
      expect{ Pubnub::Publisher.new(without_sub_key).check_config }.to raise_error(Pubnub::Publisher::ConfigNotSet)
      without_origin = valid_config.dup
      without_origin[:origin] = ""
      expect{ Pubnub::Publisher.new(without_origin).check_config }.to raise_error(Pubnub::Publisher::ConfigNotSet)
    end

    it "has a publish url for a given channel" do
      pub_client = Pubnub::Publisher.new(publish_key: "demo_pub_key", subscribe_key: "demo_sub_key", origin: "demo.pubnub.com")
      expect(pub_client.publish_url("mychannel")).to eq("https://demo.pubnub.com/publish/demo_pub_key/demo_sub_key/0/mychannel/0")
    end

    it "can prepare a http request to publish a message" do
      pub_client = Pubnub::Publisher.new(publish_key: "demo_pub_key", subscribe_key: "demo_sub_key", origin: "demo.pubnub.com")
      http, request = pub_client.prepare_message_publishing("mychannel", {text: "hey"})
      expect(http.address).to eq("demo.pubnub.com")
      expect(http.use_ssl?).to be_true
      expect(http.port).to eq(443)
      expect(request.path).to eq("/publish/demo_pub_key/demo_sub_key/0/mychannel/0/%7B%22text%22%3A%22hey%22%7D")
      expect(request).to be_instance_of(Net::HTTP::Get)
    end

    it "successfully publishes messages", integration: true do
      pub_client = Pubnub::Publisher.new(publish_key: "demo", subscribe_key: "demo")
      output = pub_client.publish("test", {text: "test from PubNub Publisher's Ruby gem"})
      expect(output).to be_true
    end

    it "handles messages which failed to publish", integration: true do
      pub_client = Pubnub::Publisher.new(publish_key: "bad-demo", subscribe_key: "demo")
      output = pub_client.publish("test", {text: "test from PubNub Publisher's Ruby gem"})
      expect(output).to be_false
    end

  end
end

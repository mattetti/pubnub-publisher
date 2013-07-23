# Pubnub::Publisher

This gem is a addon for the official [PubNub's Ruby
gem](https://github.com/pubnub/ruby). Unlike the official gem, this
doesn't have any dependencies, it relies entirely on Ruby's stdlib.

But unlike the official gem, this gem only provides one pub sub feature:
publication.

Use this library when your Ruby application only publishes events to
PubNub. For instance you might have a Go/Scala/Node.js app and many JS
clients listening on a few channels. But you need to broadcast a
message and want to do that after a trigger in your Rails app.
The cleanest way to do that is to use this gem to simply publish the
message and disconnect. This is done via PubNub's REST API.


## Installation

Add this line to your application's Gemfile:

    gem 'pubnub-publisher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pubnub-publisher

## Usage

Look at the test suite in the spec folder for more details.
The easiest way to use this library is to register a shared config at
the class level:

```ruby
Pubnub::Publisher.setup(publish_key: "your pub key", subscribe_key: "your sub key")
```

Note: I don't quite understand why Pubnub requires a subscribe key to
publish but you need to provide it otherwise the API call will fail.

You can set the following shared config keys:

* publish_key
* subscribe_key
* secret_key
* cipher_key
* origin (defaults to "pubsub.pubnub.com")
* ssl (defaults to true)
* session_uuid (randomly generated if you don't provide one)

Once you have the shared config setup, you can create an instance which
will use the default config unless instructed differently:

```ruby
pub_client = Pubnub::Publisher.new
```

You can override any of the shared config an instantiation or by using
the accessors:

```ruby
pub_client = Pubnub::Publisher.new(publish_key: "demo_pub_key", subscribe_key: "demo_sub_key", origin: "demo.pubnub.com")
```

or 

```ruby
pub_client = Pubnub::Publisher.new
pub_client.session_uuid = "ruby-app"
```

To publish a message, you call the `#publish` method passing the
channel name and a data structure that will be passed as a json.

```ruby
pub_client = Pubnub::Publisher.new
pub_client.publish("test", {text: "Hi there, this is Matt"})
```

The publication is currently blocking and will return a boolean value
so you can handle retries on your own.
Eventually, publication might have an option to happen via a thread pool
and callbacks. I would also like to persist the http connection to
improve performance.

```ruby
if pub_client.publish("test", {text: "Hi there, this is Matt"})
  Rails.logger.info "The Pubnub publishing was successful sir!"
else 
  Rails.logger.error "Something went bad with PubNub :( #wasntme"
end
```

## TODOs

* Use a thread pool to go non blocking publishing.
* use a persistent http connection to pubnub.


## Test suite

The test suite is a simple Rspec test suite, with 1 specificity: the
"integration" tag. By default, when you run the specs, the test suite
will connect to PubNub to verify that things work well. You can turn
off the integration specs by excluding them:

```
$ rspec . --tag ~integration
```

To run the full test suite:

```
$ rake
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

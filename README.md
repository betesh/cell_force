# CellForce

We use HTTParty to send SMS messages using the CellForce API.  See USAGE below for details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cell_force'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install cell_force
```

## Usage

#### Configuration

cell_force requires you to provide a username, password and API key.  Configure them before attempting to post to any AOI resource.

```ruby
CellForce.configure do |config|
  config.username = "Me"
  config.password = "MyPassword"
  config.api_key = "ReallyLongRandomString1234567789"
end
```

Since cell_force depends on sms_validation (https://github.com/betesh/sms_validation/), it is also recommended that you configure sms_validation.
cell_force uses sms_validation's logger.  In a Rails environment, you will probably want to rely on the default configuration,
but outside of Rails, you will need to configure it if you want any logging:

```ruby
SmsValidation.configure do |config|
  config.logger = ::Logger.new(STDOUT)
end
```

#### Sending an SMS

Once configured, cell_force will automatically log you in before the first API call and will store your credentials for all subsequent API calls.
cell_force transparently logs in again whenever you session expires (i.e. if you log out or if 1 hours has elapsed since your last API call).

So once configured, just fire away with API calls, which are done using CellForce::Api#post:

```ruby
api = CellForce::Api
api.post("shortcode/getusershortcodes")
api.post("shortcode/getshortcodecarriers", shortcode_id: ENV['SHORT_CODE'])
```

But don't use CellForce::Api#post to send an SMS.  If you do, you'll bypass sms_validation.  Instead, use CellForce::MobileDevice#send_mt, so that everything gets validated.

```ruby
mobile_device = CellForce::MobileDevice.new(my_phone_number)
mobile_device.send_mt(my_phone_number, "Hi, How are you?")
```
sms_validation allows you to configure what to do when a message is too long.  cell_force is only designed to work with the default behavior: :raise_error

If you need the :truncate or :split behavior instead, instantiate an SmsValidation::Sms and iterate through its messages:

```ruby
mobile_device = CellForce::MobileDevice.new(my_phone_number)

SmsValidation::Sms.new(my_phone_number, "Hi, How are you?"*387).messages.each do |message|
  mobile_device.send_mt(message)
end
```

CellForce's documentation does recommend that you log out at the end of your activity
```ruby
CellForce::Api.log_out
```

## Testing

Copy spec/secrets.yml.example to spec/secrets.yml and modify it to set appropriate credentails.  Then run `rspec`.

Note that none of the tests set any expectations.  If you run them and they all pass, it only verifies that nothing through an exception.  So make sure to check your phone after running the tests to make sure you received all the expected text messages.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cell_force/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

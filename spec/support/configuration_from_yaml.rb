require "yaml"
require "logger"
require "rspec/core/shared_context"

module ConfigurationFromYaml
  extend RSpec::Core::SharedContext
  SECRETS = YAML::load(File.open('spec/secrets.yml'))

  [:phone, :username, :password, :api_key].each do |key|
    let(key) { SECRETS[key.to_s] }
  end

  before(:each) do
    SmsValidation.configure do |config|
      config.logger = ::Logger.new(STDOUT)
    end
    CellForce.configure do |config|
      config.username, config.password, config.api_key = username, password, api_key
    end
  end
end

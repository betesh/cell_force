require "spec_helper"
require "cell_force/mobile_device"
require "support/configuration_from_yaml"

describe CellForce::MobileDevice do
  include ConfigurationFromYaml

  subject { described_class.new(phone) }

  it "should send an sms" do
    subject.send_mt("Test message via CellForce. Sent at #{Time.now}")
  end
end

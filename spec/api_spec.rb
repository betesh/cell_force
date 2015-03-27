require "spec_helper"
require "cell_force/api"
require "support/configuration_from_yaml"

describe CellForce::Api do
  include ConfigurationFromYaml

  subject { described_class }

  it "should log_out" do
    subject.log_out
  end

  describe "with the wrong API key" do
    before(:each) do
      CellForce.configuration.api_key = "12345"
    end

    after(:each) do
      CellForce.configuration.api_key = api_key
    end

    it "should raise an Api::Failure" do
      expect{subject.post("shortcode/getusershortcodes")}.to raise_error(CellForce::Api::Failure, "Invalid API Key")
    end
  end
end

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

  describe "Setting up an API Response" do
    it "should create an API response" do
      subject.post("apiresponse/enable", row_id: 12)
      subject.post("apiresponse/detail", row_id: 12)
      subject.set_api_response(id: 12, mo: "#{api_response_url}/mo", dr: "#{api_response_url}/dr", rs: "#{api_response_url}/rs", code: "Q0ol4Na54D1TenKAWf7j0d2sLuO6XU1Q")
      subject.post("apiresponse/detail", row_id: 12)
    end
  end
end

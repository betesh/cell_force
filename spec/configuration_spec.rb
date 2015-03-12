require "spec_helper"
require "cell_force/configuration"

describe CellForce::Configuration do
  subject { CellForce.configuration }

  before(:each) { reset_configuration }

  describe "#username" do
    it "cannot be nil" do
      expect{subject.username = nil}.to raise_error(CellForce::Configuration::Error, "username cannot be blank")
    end

    it "cannot be an empty String" do
      expect{subject.username = ""}.to raise_error(CellForce::Configuration::Error, "username cannot be blank")
    end

    it "cannot be a Hash" do
      expect{subject.username = {}}.to raise_error(CellForce::Configuration::Error, "username must be a String")
    end

    describe "when password and api_key are already set" do
      before(:each) do
        subject.password = "VerySecret"
        subject.api_key = "LongApiKey"
      end

      it "must be set before calling #credentials" do
        expect{subject.credentials}.to raise_error(CellForce::Configuration::Error, "username has not been set.  Set it with `CellForce.configuration.username = ...`")
      end

      it "need not be set before calling #headers" do
        expect{subject.headers}.not_to raise_error
      end
    end
  end

  describe "#password" do
    it "cannot be nil" do
      expect{subject.password = nil}.to raise_error(CellForce::Configuration::Error, "password cannot be blank")
    end

    it "cannot be an empty String" do
      expect{subject.password = ""}.to raise_error(CellForce::Configuration::Error, "password cannot be blank")
    end

    it "cannot be a Hash" do
      expect{subject.password = {}}.to raise_error(CellForce::Configuration::Error, "password must be a String")
    end

    describe "when username and api_key are already set" do
      before(:each) do
        subject.username = "Placeholder"
        subject.api_key = "LongApiKey"
      end

      it "must be set before calling #credentials" do
        expect{subject.credentials}.to raise_error(CellForce::Configuration::Error, "password has not been set.  Set it with `CellForce.configuration.password = ...`")
      end

      it "need not be set before calling #headers" do
        expect{subject.headers}.not_to raise_error
      end
    end
  end

  describe "#api_key" do
    it "cannot be nil" do
      expect{subject.api_key = nil}.to raise_error(CellForce::Configuration::Error, "api_key cannot be blank")
    end

    it "cannot be an empty String" do
      expect{subject.api_key = ""}.to raise_error(CellForce::Configuration::Error, "api_key cannot be blank")
    end

    it "cannot be a Hash" do
      expect{subject.api_key = {}}.to raise_error(CellForce::Configuration::Error, "api_key must be a String")
    end

    describe "when username and password are already set" do
      before(:each) do
        subject.username = "Placeholder"
        subject.password = "VerySecret"
      end

      it "need not be set before calling #credentials" do
        expect{subject.credentials}.not_to raise_error
      end

      it "must be set before calling #headers" do
        expect{subject.headers}.to raise_error(CellForce::Configuration::Error, "api_key has not been set.  Set it with `CellForce.configuration.api_key = ...`")
      end
    end
  end

  describe "#credentials" do
    let(:username) { "PercyWeasley" }
    let(:password) { "FredWeasley" }

    let(:new_username) { "GeorgeWeasley" }
    let(:new_password) { "RonaldWeasley" }

    before(:each) do
      CellForce.configure do |config|
        config.username = username
        config.password = password
      end
    end

    it "should contain username and password" do
      expect(subject.credentials).to eq(username: username, password: password)
    end

    it "should detect changes to username" do
      expect{subject.username = new_username}.to change{subject.credentials}.from(username: username, password: password).to(username: new_username, password: password)
    end

    it "should detect changes to password" do
      expect{subject.password = new_password}.to change{subject.credentials}.from(username: username, password: password).to(username: username, password: new_password)
    end
  end

  describe "#headers" do
    let(:api_key) { "DracoMalfoy" }
    let(:new_api_key) { "HarryPotter" }

    before(:each) do
      CellForce.configure do |config|
        config.api_key = api_key
      end
    end

    it "should contain api_key" do
      expect(subject.headers).to eq("apikey" => api_key)
    end

    it "should detect changes to username" do
      expect{subject.api_key = new_api_key}.to change{subject.headers}.from("apikey" => api_key).to("apikey" => new_api_key)
    end
  end
end

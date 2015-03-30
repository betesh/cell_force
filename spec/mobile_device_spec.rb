require "spec_helper"
require "cell_force/mobile_device"
require "support/configuration_from_yaml"

describe CellForce::MobileDevice do
  include ConfigurationFromYaml

  subject { described_class.new(phone) }
  let(:api) { CellForce::Api }

  it "should send an sms" do
    subject.send_mt("Test message via CellForce. Sent at #{Time.now}")
  end

  describe "simulating an MO" do
    def clean_up
      keyword_record = api.post("keyword/list").data.find{ |r| keyword == r["keyword"] }
      if keyword_record
        api.post("campaign/list").data.each do |campaign|
          if keyword_record["id"] == api.post("campaign/detail", row_id: campaign["campaign_id"]).data["keyword_id"]
            api.post("campaign/delete", row_id: campaign["campaign_id"])
          end
        end
        api.post("keyword/delete", row_id: keyword_record["id"])
      end
    end

    let(:keyword) { "CDF" }
    let(:keyword_id) do
      api.post("keyword/create", keyword: keyword, shortcodes: subject.send(:short_code_id)).data["row_id"]
    end

    let(:campaign_id) do
      api.post(
        "campaign/tcpaoptin",
        keyword_id: keyword_id,
        shortcode_id: subject.send(:short_code_id),
        optinkeyword: "Y",
        name: "Opt in to Keyword #{keyword}",
        message: "Welcome to keyword #{keyword} campaigns.  To join, reply Y",
        doubleoptinmessage: "Thanks, you have joined keyword #{keyword} campaigns",
        errormessage: "We could not understand your response.  Please reply Y to join"
      ).data["campaign_id"]
    end

    before(:each) do
      clean_up
    end

    let(:campaign_options) {
      {
        name: "Opt in to Keyword #{keyword}",
        first_message: "Welcome to keyword #{keyword} campaigns.  To join, reply Y",
        second_message: "Thanks, you have joined keyword #{keyword} campaigns",
        error_message: "We could not understand your response.  Please reply Y to join"
      }
    }

    after(:each) do
      tcpa_opt_in = CellForce::TcpaOptInCampaign.new(keyword)
      tcpa_opt_in.campaign_ids.each do |id|
        api.post("campaign/delete", row_id: id)
      end
      api.post("keyword/delete", row_id: tcpa_opt_in.keyword_id)
    end

    it "should simulate an MO when the keyword does not already exist" do
      subject.simulate_mo(keyword, campaign_options)
    end

    it "should simulate an MO when the keyword exists but the campaign does not" do
      keyword_id
      subject.simulate_mo(keyword, campaign_options)
    end

    it "should simulate an MO when the keyword and campaign already exist" do
      campaign_id
      subject.simulate_mo(keyword)
    end
  end
end

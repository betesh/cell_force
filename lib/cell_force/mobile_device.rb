require "cell_force/default_short_code"
require "cell_force/tcpa_opt_in_campaign"

module CellForce
  class MobileDevice
    include DefaultShortCode

    attr_reader :phone, :short_code
    def initialize(phone, short_code=nil)
      @phone, @short_code = phone, short_code
    end

    def create!
      post("member/create", member_info: { cellnumber: phone, country_id: Api.united_states_id, carrier: carrier_id })
    end

    def send_mt(message)
      Api.post(Api::SEND_SMS_RESOURCE, sms_validation: SmsValidation::Sms.new(phone, message), shortcode_id: short_code_id).data["mt_id"]
    end

    def simulate_mo(keyword, campaign_options={})
      tcpa_opt_in_campaign = TcpaOptInCampaign.new(keyword)
      if tcpa_opt_in_campaign.campaign_ids.empty?
        tcpa_opt_in_campaign.create_campaign(campaign_options)
      end
      Api.post("sms/mo", cellnumber: phone, message: keyword, shortcode_id: short_code_id, carrier_id: carrier_id, trigger: "DOUBLEOPTIN")
    end

    private
    def carrier_id
      @carrier_id ||= Api.post("member/networklookup", cellphone: phone).data["id"]
    end
  end
end

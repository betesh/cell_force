require "cell_force/default_short_code"

module CellForce
  class MobileDevice
    include DefaultShortCode

    attr_reader :phone, :short_code
    def initialize(phone, short_code=nil)
      @phone, @short_code = phone, short_code
    end

    def send_mt(message)
      Api.post(Api::SEND_SMS_RESOURCE, sms_validation: SmsValidation::Sms.new(phone, message), shortcode_id: short_code_id)
    end

    def simulate_mo(keyword)
      Api.post("sms/mo", cellnumber: phone, message: keyword, shortcode_id: short_code_id, carrier_id: carrier_id, trigger: "DOUBLEOPTIN")
    end

    private
    def carrier_id
      @carrier_id ||= Api.post("member/networklookup", cellphone: phone).data["id"]
    end
  end
end

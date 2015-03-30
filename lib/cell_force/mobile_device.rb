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
  end
end

require "cell_force/api"

module CellForce
  class MobileDevice
    attr_reader :phone, :short_code
    def initialize(phone, short_code=nil)
      @phone, @short_code = phone, short_code
    end

    def send_mt(message)
      Api.post(Api::SEND_SMS_RESOURCE, sms_validation: SmsValidation::Sms.new(phone, message), shortcode_id: short_code_id)
    end

    private
    def short_code_id
      @short_code_id ||= begin
        data = Api.post("shortcode/getusershortcodes").data
        if short_code
          data.find{ |e| short_code.to_s == e["shortcode"].to_s }
        else
          # If the instance was not initialized with a short_code, we use the first one we find
          data[0].tap { |s| @short_code = s["shortcode"] }
        end["shortcode_id"]
      end
    end
  end
end

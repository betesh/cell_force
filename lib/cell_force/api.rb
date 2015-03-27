require "httparty"
require "sms_validation"
require "cell_force/configuration"

module CellForce
  class Api
    class Http
      include HTTParty
      base_uri "https://www.mycellforce.com"
    end

    module Util
      class << self
        def filtered(hash)
          hash.is_a?(Hash) ? hash.reject{ |k,v| PARAMETER_FILTER.include?(k.to_sym) } : hash
        end

        def hash_to_log(hash)
          hash.sort_by{ |k,v| k }.collect{|k,v| "\t\t\t#{k}:#{" " * [(15 - k.length),0].max}\t#{v}" }.join("\n")
        end

        def parse_response(response)
          body = JSON.parse(response.body)
          SmsValidation.log { "CellForce API: #{response.code}:#{response.message}" }
          SmsValidation.configuration.logger.debug { "\n\t\tHeaders:\n#{hash_to_log(response.headers)}" }
          SmsValidation.log { "\n\t\tBody:\n#{hash_to_log(body.inject({}) { |hash, (k,v)| hash[k] = filtered(v); hash })}" }
          raise Failure, body["error"] if "failure" == body["status"]
          Struct.new(*body.keys.collect(&:to_sym)).new(*body.values)
        end

        def convert_sms_args(args)
          validation = args.delete(:sms_validation)
          unless validation.is_a?(SmsValidation::Sms)
            raise StandardError, "You cannot send an SMS by calling #{CellForce::Api}#post directly.  Use #{CellForce::Api}#send_sms(phone, message) instead."
          end
          args.merge(cellnumber: validation.phone[1..-1], message: validation.message)
        end
      end
    end

    class Failure < StandardError; end

    LOG_IN_RESOURCE = "users/login"
    SEND_SMS_RESOURCE = "member/sendsms"
    PARAMETER_FILTER = [:password, :user_key]

    class << self
      def post(resource, body={})
        body = Util.convert_sms_args(body.dup) if SEND_SMS_RESOURCE == resource
        Util.parse_response(post_with_automatic_login(resource, body))
      end

      def log_out
        post("users/logout").tap { @login_data = nil }
      end

      def set_api_response(args={})
        callback = args.key?(:id) ? :update : :create
        mo, dr, rs = args[:mo], args[:dr], args[:rs]
        post("apiresponse/#{callback}", moflag: (mo ? 1 : 0), drflag: (dr ? 1 : 0), rsflag: (rs ? 1 : 0), mourl: mo || "", drurl: dr || "", rsurl: rs || "", code: args[:code], row_id: args[:id])
      end

      def united_states_id
        @united_states_id ||= post("member/getdata").data["countries"].find{ |country| "United States" == country["country"] }["id"]
      end

      private
      def post_with_automatic_login(resource, body)
        body = body.merge(login_data) unless LOG_IN_RESOURCE == resource
        SmsValidation.log { "CellForce API: POST #{resource}#{filtered_body = Util.filtered(body); " -- #{filtered_body.inspect}" unless filtered_body.empty?}" }
        result = Http.post("/exlapiservice/#{resource}", headers: configuration.headers, body: body )
        if "The user key is invalid" == JSON.parse(result.body)["error"]
          @login_data = nil
          post_with_automatic_login(resource, body)
        else
          result
        end
      end

      def configuration
        CellForce.configuration
      end

      def login_data
        @login_data ||= begin
          SmsValidation.log { "CellForce API: Logged out.  Logging in again..." }
          post(LOG_IN_RESOURCE, configuration.credentials).data
        end
      end
    end
  end
end

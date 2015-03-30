require "cell_force/default_short_code"

module CellForce
  class TcpaOptInCampaign
    include DefaultShortCode

    REQUIRED_KEYS_TO_CREATE_CAMPAIGN = [:name, :first_message, :second_message, :error_message]

    attr_reader :keyword, :short_code
    def initialize(keyword, short_code=nil)
      @keyword, @short_code = keyword, short_code
    end

    def keyword_id
      @keyword_id ||= begin
        begin
          Api.post("keyword/create", keyword: keyword, shortcodes: short_code_id, action: "check").data["message"]
          Api.post("keyword/create", keyword: keyword, shortcodes: short_code_id).data["row_id"]
        rescue CellForce::Api::Failure => e
          raise e unless e.to_s == "Keyword is already Exist"
          if (keyword_record = Api.post("keyword/list").data.find{ |r| keyword == r["keyword"] }) #Intentional assignment operator
            keyword_record["id"]
          else
            raise StandardError, "This keyword is already in use by another consumer of the short_code #{short_code}"
          end
        end
      end
    end

    def campaign_ids
      @campaign_ids ||= Api.post("campaign/list").data.collect do |campaign|
        campaign["campaign_id"] if keyword_id == Api.post("campaign/detail", row_id: campaign["campaign_id"]).data["keyword_id"]
      end.compact
    end

    def create_campaign(options)
      raise ArgumentError, "Some options were missing for creating a campaign: #{REQUIRED_KEYS_TO_CREATE_CAMPAIGN - options.keys}" unless (REQUIRED_KEYS_TO_CREATE_CAMPAIGN - options.keys).empty?
      Api.post("campaign/tcpaoptin", keyword_id: keyword_id, shortcode_id: short_code_id, optinkeyword: "Y", name: options[:name], message: options[:first_message], doubleoptinmessage: options[:second_message], errormessage: options[:error_message]).data["campaign_id"]
    end
  end
end

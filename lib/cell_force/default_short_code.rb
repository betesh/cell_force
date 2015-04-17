require "cell_force/api"

module CellForce
  module DefaultShortCode
    def short_code_id=(_)
      @short_code_id = _
    end

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

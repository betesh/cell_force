$LOAD_PATH << File.expand_path("#{File.dirname(__FILE__)}/lib") << File.expand_path(File.dirname(__FILE__))
require "cell_force"

namespace :cell_force do
  desc "configure CellForce API"
  task :configure do
    require "sms_validation"
    SmsValidation.configure do |config|
      require "logger"
      config.logger = ::Logger.new(STDOUT)
      config.logger.level = Logger::INFO
      config.log_at :info
    end

    require "yaml"
    secrets = YAML::load(File.open('spec/secrets.yml'))
    CellForce.configure do |config|
      config.username, config.password, config.api_key = secrets["username"], secrets["password"], secrets["api_key"]
    end
  end

  desc "Reserve a keyword (KEYWORD=XXX rake cell_force:reserve_keyword)"
  task reserve_keyword: :configure do
    CellForce::TcpaOptInCampaign.new(ENV['KEYWORD']).keyword_id
  end

  desc "Enable a keyword (KEYWORD=XXX rake cell_force:enable_keyword)"
  task enable_keyword: :configure do
    CellForce::Api.post("keyword/enable", row_id: CellForce::TcpaOptInCampaign.new(ENV['KEYWORD']).keyword_id)
  end

  desc "Send an MT (PHONE=NNNNNNNNNN rake cell_force:send_mt)"
  task send_mt: :configure do
    CellForce::MobileDevice.new(ENV['PHONE']).send_mt("Test message via CellForce. Sent at #{Time.now}")
  end
end

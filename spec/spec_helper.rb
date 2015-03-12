RSpec.configure do |config|
  def reset_configuration
    CellForce.instance_variable_set("@configuration", nil)
  end

  config.after(:all) { reset_configuration }
end

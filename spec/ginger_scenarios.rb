require 'ginger'

class ScenarioWithName < Ginger::Scenario
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

def is_ruby_19?
  RUBY_VERSION[0..2].eql?('1.9')
end

def create_scenario(version)
  scenario = ScenarioWithName.new("Rails #{version} on ruby: #{[RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_RELEASE_DATE, RUBY_PLATFORM].join(' ')}")
  scenario[/^active_?support$/]    = version
  scenario[/^active_?record$/]     = version
  scenario[/^action_?pack$/]       = version
  scenario[/^action_?controller$/] = version
  scenario[/^rails$/] = version
  scenario
end

Ginger.configure do |config|
  config.aliases["active_record"] = "activerecord"
  config.aliases["active_support"] = "activesupport"
  config.aliases["action_controller"] = "actionpack"

  rails_1_2_6 = ScenarioWithName.new("Rails 1.2.6")
  rails_1_2_6[/^active_?support$/] = "1.4.4"
  rails_1_2_6[/^active_?record$/] = "1.15.6"
  rails_1_2_6[/^action_?pack$/] = "1.13.6"
  rails_1_2_6[/^action_?controller$/] = "1.13.6"
  rails_1_2_6[/^rails$/] = "1.2.6"

  unless is_ruby_19?
    config.scenarios << rails_1_2_6
    config.scenarios << create_scenario("2.0.2")
    config.scenarios << create_scenario("2.1.2")
    config.scenarios << create_scenario("2.2.2")
    config.scenarios << create_scenario("2.3.2")
  end
  config.scenarios << create_scenario("2.3.3")
  config.scenarios << create_scenario("2.3.4")
  config.scenarios << create_scenario("2.3.5")
end
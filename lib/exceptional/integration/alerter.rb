module Exceptional
  class Alert <StandardError;
  end

  module Integration
    def self.alert(msg, env={})
      return Exceptional::Sender.error(Exceptional::AlertData.new(Alert.new(msg), "Alert"))
    end
  end
end


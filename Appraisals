rails_versions = ::File.read("TESTED_RAILS_VERSIONS").split
rails_versions.each do |rails_version|
  appraise "#{rails_version}" do
    gem "rails", "~> #{rails_version}"
    gem "exceptional", :path => "../"
  end
end

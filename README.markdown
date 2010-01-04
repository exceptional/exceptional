# Exceptional plugin for Ruby on Rails

This plugin posts exception data to Exceptional (http://getexceptional.com). Data about the request, session, environment and a backtrace of the exception is transmitted.

Once installed and configured, all exceptions from web requests are reported to Exceptional.

## Installation

1. gem install exceptional
2. Add config.gem entry to 'config/environment.rb'
<pre>config.gem 'exceptional', :version => '2.0.2'</pre>
3. run 'exceptional install <api-key>' using the api-key for your app from http://getexceptional.com

### Other ways to install:

1. traditional rails plugin install
2. gem bundler

## Upgrading from old version of the exceptional plugin

1. Delete vendor/plugins/exceptional
2. Follow installation instructions above
3. (optional) Simplify your config/exceptional.yml file - all it needs now is a single line with 'api-key: YOUR-KEY'


## Usage outside web requests (Daemons etc)

Exceptional.resuce do
  something_that_you_want_to_catch_exceptions_from
end

This reports exceptions to Exceptional and re-raises them.

### (Optional) Loading exceptional config

You can either do something like

Exceptional::Config.load("config/exceptional.yml")

or

Exceptional.configure('YOUR_API-KEY')


Please send any questions or comments to feedback@getexceptional.com.

Copyright © 2008, 2009 Contrast.
# Exceptional 

Exceptional helps you track errors in your Ruby apps

This Gem/Plugin posts exception data to Exceptional <http://getexceptional.com>. Data about the request, session, environment and a backtrace of the exception is transmitted.

## Rails Installation

1. gem install exceptional
2. Add config.gem entry to 'config/environment.rb'
<pre>config.gem 'exceptional', :version => '2.0.8'</pre>
3. run 'exceptional install <api-key>' using the api-key for your app from http://getexceptional.com

### Exceptional also supports your rack, sinatra and plain ruby apps

For more information please check out <http://getexceptional.com> or our docs site at <http://docs.getexceptional.com>


Copyright © 2008, 2009 Contrast.
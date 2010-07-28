# Exceptional <http://getexceptional.com>

Exceptional helps you track errors in your Ruby apps

This Gem/Plugin posts exception data to Exceptional <http://getexceptional.com>. Data about the request, session, environment and a backtrace of the exception is sent.

## Rails 2.x Installation

1. Install the Gem
<pre>gem install exceptional</pre>
2. Add config.gem entry to 'config/environment.rb'
<pre>config.gem 'exceptional'
3. Create your account and app at <http://getexceptional.com>
4. Configue your API Key
<pre>$ exceptional install <api-key></pre>
using the api-key from the app settings screen within Exceptional
5. Test with <pre>exceptional test</pre>

## Rails 3 Installation

1. Add  gem entry to Gemfile
<pre>config.gem 'exceptional'</pre>
2. Run <pre>bundle install</pre>
3. Create your account and app at <http://getexceptional.com>
4. Configue your API Key
<pre>$ exceptional install <api-key></pre>
using the api-key from the app settings screen within Exceptional
5. Test with <pre>exceptional test</pre>


### Exceptional also supports your rack, sinatra and plain ruby apps
For more information check out our docs site <http://docs.getexceptional.com>

Copyright © 2008, 2010 Contrast.
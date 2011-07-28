# Exceptional <http://getexceptional.com>

Exceptional helps you track errors in your Ruby apps

This Gem/Plugin posts exception data to Exceptional <http://getexceptional.com>. Data about the request, session, environment and a backtrace of the exception is sent.

## Rails 2.x Installation

1.  Install the Gem
    
    ```
    $ gem install exceptional
    ```
    
2.  Add config.gem entry to 'config/environment.rb'
    
    ```ruby
    config.gem 'exceptional'
    ```
    
3.  Create your account and app at <http://getexceptional.com>
    
4.  Configue your API Key
    
    ```
    $ exceptional install <api-key>
    ```
    
    using the api-key from the app settings screen within Exceptional

5.  Test with <code>exceptional test</cocde>
    
## Rails 3 Installation

1.  Add  gem entry to Gemfile
    
    ```ruby
    gem 'exceptional'
    ```
    
2.  Run <code>bundle install</code>

3.  Create your account and app at <http://getexceptional.com>

4.  Configue your API Key
    
    ```
    $ exceptional install <api-key>
    ```
    
    using the api-key from the app settings screen within Exceptional

5.  Test with <code>exceptional test</code>


### Exceptional also supports your rack, sinatra and plain ruby apps
For more information check out our docs site <http://docs.getexceptional.com>

Copyright © 2008, 2010 Contrast.

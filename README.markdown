# Exceptional <http://exceptional.io>

Exceptional helps you track errors in your Ruby apps

This Gem/Plugin posts exception data to Exceptional <http://exceptional.io>. Data about the request, session, environment and a backtrace of the exception is sent.

## Rails 2.x Installation

1.  Install the Gem
    
    ```
    $ gem install exceptional
    ```
    
2.  Add config.gem entry to 'config/environment.rb'
    
    ```ruby
    config.gem 'exceptional'
    ```
    
3.  Create your account and app at <http://exceptional.io>
    
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

3.  Create your account and app at <http://exceptional.io>

4.  Configue your API Key
    
    ```
    $ exceptional install <api-key>
    ```
    
    using the api-key from the app settings screen within Exceptional

5.  Test with <code>exceptional test</code>

## Reporting exceptions in development

Exceptional will not report your exceptions in *development* environment by default. 

To enable reporting of exceptions in development, please add the following lines to your `exceptional.yml`.

```ruby
development:

  enabled: true
```

To write Exceptional information to the log or STDOUT instead of sending it to the remote API, add the following line to your `exceptional.yml`.

```ruby
development:

  send_to: stdout
```

This allows you to monitor Exceptional processing in development mode. Valid values for `send_to` are `api` (the default), `log` and `stdout`.

You can provide custom printers for the `log` and `stdout` destinations. For example, if you like using [`AwesomePrint`](https://github.com/michaeldv/awesome_print), you can use something like:

```ruby
Exceptional::Config.stdout_printer = lambda do |exception_data|
  ap ["@@@ Exceptional error", exception_data]
end

Exceptional::Config.log_printer = lambda do |exception_data|
  Rails.logger.ap ["@@@ Exceptional error", exception_data], :error
end
```

## Multiple Rails environments
To use Exceptional within multiple Rails environments, edit your
config/exceptional.yml to look like the following

```
development:
  enabled: true
  api-key: your-dev-api-key

production:
  enabled: true
  api-key: you-prod-api-key
```

### Exceptional also supports your rack, rake, sinatra and plain ruby apps
For more information check out our docs site <http://docs.exceptional.io> 
Or visit our knowledge base <http://support.exceptional.io/>

Copyright © 2008 - 2012 Exceptional Cloud Services.

require File.dirname(__FILE__) + '/../spec_helper'
require 'digest/md5'

class Exceptional::FunkyError < StandardError
  def backtrace
    'backtrace'
  end
end

describe Exceptional::ControllerExceptionData do
  it "raises useful error when to_json isn't available on to_hash" do
    begin
      data = Exceptional::ExceptionData.new(Exceptional::FunkyError.new)
      hash_without_json = {}
      hash_without_json.stub!(:to_json).and_raise(NoMethodError)
      data.stub!(:to_hash).and_return(hash_without_json)
      data.to_json
      fail 'expects to raise and error'
    rescue StandardError => e
      e.message.should =~ /to_json/
    end
  end
end

describe Exceptional::ControllerExceptionData, 'when no request/controller/params' do
  before :each do
    ENV['LOGNAME'] = 'bob'
    ENV['SOMETHING_SECRET'] = 'secretPasswords'
    ENV['DATABASE_URL'] = 'something'
    ENV['SOMETHING_INTERESTING'] = 'instagram'
    ENV['HTTP_SOMETHING'] = 'should be stripped'
    ENV['FILTERED_BY_OLD_FILTER_CONFIG'] = 'should_be_filtered'
    Exceptional::ENVIRONMENT_WHITELIST << /_INTERESTING/
    Exceptional::ENVIRONMENT_WHITELIST << 'FILTERED_BY_OLD_FILTER_CONFIG'
    Exceptional::ENVIRONMENT_FILTER << 'FILTERED_BY_OLD_FILTER_CONFIG'
    ::RAILS_ENV = 'test' unless defined?(RAILS_ENV)
    Time.stub!(:now).and_return(Time.mktime(1970, 1, 1))
    error = Exceptional::FunkyError.new('some message')
    @data = Exceptional::ControllerExceptionData.new(error)
    @hash = @data.to_hash
  end

  it "capture exception details" do
    error_hash = @hash['exception']
    error_hash['exception_class'].should == 'Exceptional::FunkyError'
    error_hash['message'].should == 'some message'
    error_hash['backtrace'].should == 'backtrace'
    DateTime.parse(error_hash['occurred_at']).should == DateTime.now
    client_hash = @hash['client']
    client_hash['name'].should == Exceptional::CLIENT_NAME
    client_hash['version'].should == Exceptional::VERSION
    client_hash['protocol_version'].should == Exceptional::PROTOCOL_VERSION
  end

  it "has sensible initial ENVIRONMENT_WHITELIST" do
    %w(HOME PATH PWD RUBYOPT GEM_HOME RACK_ENV RAILS_ENV BUNDLE_GEMFILE BUNDLE_BIN_PATH).each do |expected_to_be_whitelisted|
      Exceptional::ENVIRONMENT_WHITELIST.should include(expected_to_be_whitelisted)
    end
  end

  it "uses a whitelist for ENV variables aswell as existing filter" do
    env = @hash['application_environment']['env']
    env['SOMETHING_SECRET'].should be_nil
    env['DATABASE_URL'].should be_nil
    env['HTTP_SOMETHING'].should be_nil
    env['FILTERED_BY_OLD_FILTER_CONFIG'].should be_nil
    env['SOMETHING_INTERESTING'].should == 'instagram'
  end

  it "generates parseable json" do
    require 'json'
    JSON.parse(@data.to_json)['exception']['exception_class'].should == 'Exceptional::FunkyError'
  end

  it "capture application_environment" do
    application_env_hash = @hash['application_environment']
    application_env_hash['environment'].should == 'test'
    application_env_hash['env'].should_not be_nil
    application_env_hash['host'].should == `hostname`.strip
    application_env_hash['run_as_user'].should == 'bob'
    application_env_hash['application_root_directory'].should == Dir.pwd
    application_env_hash['language'].should == 'ruby'
    application_env_hash['language_version'].should == "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} #{RUBY_RELEASE_DATE} #{RUBY_PLATFORM}"
    application_env_hash['framework'].should == "rails"
    application_env_hash['libraries_loaded']['rails'].should =~ /\d\.\d\.\d/
  end
end

describe Exceptional::ControllerExceptionData, 'with request/controller/params' do
  class Exceptional::SomeController < ActionController::Base
    filter_parameter_logging :filter_me
  end

  before :each do
    @controller = Exceptional::SomeController.new
    @request = ActionController::TestRequest.new({'action' => 'some_action' })
    @request.request_uri = '/some_path?var1=abc'
    @request.stub!(:parameters).and_return({'var1' => 'abc', 'action' => 'some_action', 'filter_me' => 'private'})
    @request.stub!(:request_method).and_return(:get)
    @request.stub!(:remote_ip).and_return('1.2.3.4')
    @request.stub!(:env).and_return({'SOME_VAR' => 'abc', 'HTTP_CONTENT_TYPE' => 'text/html'})
    @error = Exceptional::FunkyError.new('some message')
    data = Exceptional::ControllerExceptionData.new(@error, @controller, @request)
    @hash = data.to_hash
  end

  it "captures request" do
    request_hash = @hash['request']
    request_hash['url'].should == 'http://test.host/some_path?var1=abc'
    request_hash['controller'].should == 'Exceptional::SomeController'
    request_hash['action'].should == 'some_action'
    request_hash['parameters'].should == {'var1' => 'abc', 'action' => 'some_action', 'filter_me' => '[FILTERED]'}
    request_hash['request_method'].should == 'get'
    request_hash['remote_ip'].should == '1.2.3.4'
    request_hash['headers'].should == {'Content-Type' => 'text/html'}
  end

  it "filter out objects that aren't jsonable" do
    class Crazy
      def initialize
        @bar = self
      end
    end
    crazy = Crazy.new
    input = {'crazy' => crazy, :simple => '123', :some_hash => {'1' => '2'}, :array => ['1', '2']}
    Exceptional::ControllerExceptionData.sanitize_hash(input).should == {'crazy' => crazy.to_s, :simple => '123', :some_hash => {'1' => '2'}, :array => ['1', '2']}
  end
  
  it "allow if non jsonable objects are hidden in an array" do
    class Bonkers
      def to_json
        no.can.do!
      end
    end
    crazy = Bonkers.new
    input = {'crazy' => [crazy]}
    Exceptional::ControllerExceptionData.sanitize_hash(input).should == {'crazy' => [crazy.to_s]}    
  end

  it "filter params specified in env['action_dispatch.parameter_filter']" do
    @request.stub!(:env).and_return({'SOME_VAR' => 'abc', 'HTTP_CONTENT_TYPE' => 'text/html', 'action_dispatch.parameter_filter' => [:var1]})
    @request.stub!(:parameters).and_return({'var1' => 'abc'})
    data = Exceptional::ControllerExceptionData.new(@error, @controller, @request)
    data.to_hash['request']['parameters'].should == {'var1' => '[FILTERED]'}
  end

  it "filter nested params specified in env['action_dispatch.parameter_filter']" do
    @request.stub!(:env).and_return({'SOME_VAR' => 'abc', 'HTTP_CONTENT_TYPE' => 'text/html', 'action_dispatch.parameter_filter' => [:var1]})
    @request.stub!(:parameters).and_return({'var1' => {'var2' => 'abc','var3' => "abc"}})
    data = Exceptional::ControllerExceptionData.new(@error, @controller, @request)
    data.to_hash['request']['parameters'].should == {'var1' => '[FILTERED]'}
  end

  it "formats the occurred_at as iso8601" do
    @request.stub!(:env).and_return({'SOME_VAR' => 'abc', 'HTTP_CONTENT_TYPE' => 'text/html', 'action_dispatch.parameter_filter' => [:var1]})
    @request.stub!(:parameters).and_return({'var1' => 'abc'})
    data = Exceptional::ControllerExceptionData.new(@error, @controller, @request)
    data.to_hash['exception']['occurred_at'].should match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.{1,6}$/)
  end

  it "ArgumentError bug with file object" do
    file = File.new(File.expand_path('../../fixtures/favicon.png',__FILE__))
    @request.stub!(:parameters).and_return({'something' => file })
    data = Exceptional::ControllerExceptionData.new(@error, @controller, @request)
    data.to_hash['request']['parameters']['something'].should == file.to_s
  end

  it "to_strings regex because JSON.parse(/aa/.to_json) doesn't work" do
    input = {'crazy' => /abc.*/}
    Exceptional::ExceptionData.sanitize_hash(input).should == {'crazy' => /abc.*/.to_s}
  end

  it "handles session objects with various interfaces" do
    class SessionWithInstanceVariables
      def initialize
        @data = {'a' => '1', 'b' => /hello there Im a regex/i}
        @session_id = '123'
      end
    end
    
    request = ActionController::TestRequest.new
    session = SessionWithInstanceVariables.new
    request.stub!(:session).and_return(session)
    request.stub!(:session_options).and_return({})
    Exceptional::ControllerExceptionData.sanitize_session(request).should == {'session_id' => '123', 'data' => {'a' => '1', 'b' => "(?i-mx:hello there Im a regex)"}}
    session = mock('session', :session_id => '123', :instance_variable_get => {'a' => '1', 'b' => /another(.+) regex/mx})
    request.stub!(:session).and_return(session)
    Exceptional::ControllerExceptionData.sanitize_session(request).should == {'session_id' => '123', 'data' => {'a' => '1', 'b' => "(?mx-i:another(.+) regex)"}}
    session = mock('session', :session_id => nil, :to_hash => {:session_id => '123', 'a' => '1'})
    request.stub!(:session).and_return(session)
    Exceptional::ControllerExceptionData.sanitize_session(request).should == {'session_id' => '123', 'data' => {'a' => '1'}}
    request.stub!(:session_options).and_return({:id => 'xyz'})
    Exceptional::ControllerExceptionData.sanitize_session(request).should == {'session_id' => 'xyz', 'data' => {'a' => '1'}}
  end

  it "filter session cookies from headers" do
    @request.stub!(:env).and_return({'SOME_VAR' => 'abc', 'HTTP_COOKIE' => '_something_else=faafsafafasfa; _myapp-lick-nation_session=BAh7DDoMbnVtYmVyc1sJaQZpB2kIaQk6FnNvbWVfY3Jhenlfb2JqZWN0bzobU3Bpa2VDb250cm9sbGVyOjpDcmF6eQY6CUBiYXJABzoTc29tZXRoaW5nX2Vsc2UiCGNjYzoKYXBwbGUiDUJyYWVidXJuOgloYXNoewdpBmkHaQhpCToPc2Vzc2lvbl9pZCIlMmJjZTM4MjVjMThkNzYxOWEyZDA4NTJhNWY1NGQzMmU6C3RvbWF0byIJQmVlZg%3D%3D--66fb4606851f06bf409b8bc4ba7aea47a0259bf7'})
    @hash = Exceptional::ControllerExceptionData.new(Exceptional::FunkyError.new('some message'), @controller, @request).to_hash
    @hash['request']['headers'].should == {'Cookie' => '_something_else=faafsafafasfa; _myapp-lick-nation_session=[FILTERED]'}
  end

  it "creates a uniqueness_hash from backtrace" do
    exception = Exception.new
    exception.stub!(:backtrace).and_return(['123'])
    data = Exceptional::ControllerExceptionData.new(exception)
    data.uniqueness_hash.should == Digest::MD5.hexdigest('123')
  end
  
  it "creates a nil uniqueness_hash if nil backtrace" do
    exception = Exception.new
    exception.stub!(:backtrace).and_return(nil)
    data = Exceptional::ControllerExceptionData.new(exception)
    data.uniqueness_hash.should == nil
  end
  
  it "creates a uniqueness_hash from backtrace" do
    exception = Exception.new
    exception.stub!(:backtrace).and_return([])
    data = Exceptional::ControllerExceptionData.new(exception)
    data.uniqueness_hash.should == nil
  end
end

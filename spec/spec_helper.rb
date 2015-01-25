ENV['RACK_ENV'] = 'test'

require 'napa/setup'
require 'acts_as_fu'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

Napa.skip_initialization = true

require 'napa'
require 'napa/rspec_extensions/response_helpers'

module NapaSpecHelpers
  class MockApp
    def initialize(return_values={})
      @status  = return_values.fetch :status,  200
      @headers = return_values.fetch :headers, {'Content-Type' => 'text/html'}
      @body    = return_values.fetch :body,    ["the body"]
    end

    attr_reader :provided_env
    def call(env)
      @provided_env = env
      [@status, @headers, @body]
    end
  end

  def mockapp(return_values={})
    MockApp.new return_values
  end

  def middleware_request_for(middleware, *args, &block)
    Rack::MockRequest.new(
      Rack::Lint.new(
        middleware.new(*args, &block)
      )
    )
  end

  # Redirects stderr and stdout to /dev/null.
  def silence_output
    @orig_stderr = $stderr
    @orig_stdout = $stdout

    # redirect stderr and stdout to /dev/null
    $stderr = File.new('/dev/null', 'w')
    $stdout = File.new('/dev/null', 'w')
  end

  # Replace stdout and stderr so anything else is output correctly.
  def enable_output
    $stderr = @orig_stderr
    $stdout = @orig_stdout
    @orig_stderr = nil
    @orig_stdout = nil
  end
end

# from https://gist.github.com/adamstegman/926858
RSpec.configure do |config|
  config.include Napa::RspecExtensions::ResponseHelpers
  config.include NapaSpecHelpers

  config.before(:all) { silence_output }
  config.after(:all) { enable_output }

  config.include ActsAsFu

  config.before(:each) do
    allow(Napa).to receive(:initialize)
    allow(Napa::Logger).to receive_message_chain('logger.info').with(:napa_deprecation_warning)
  end
end

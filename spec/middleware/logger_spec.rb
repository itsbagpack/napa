require 'spec_helper'
require 'rack/test'
require 'napa/middleware/logger'

# use Napa::Middleware::Logger,
#   filter: [:password, :password_confirmation, :cvv, :card_number]

describe Napa::Middleware::Logger do
  def middleware_request_for(*args, &block)
    super described_class, *args, &block
  end

  attr_accessor :info_logged, :debug_logged

  before do
    allow(Napa::Logger).to receive_message_chain('logger.info')  { |logged|
      self.info_logged = logged
    }
    allow(Napa::Logger).to receive_message_chain('logger.debug') { |logged|
      self.debug_logged = logged
    }
  end

  describe 'logs the request' do
    it 'logs request_method, path, query, host, pid, revision, params, and remote_ip'
    it 'logs the user_id, if there is a current_user method... I don\'t know where that would come from, though'
    it 'filters out sensitive data'
  end

  describe 'logs the response' do
    it 'logs the status headers, and body, according to the Napa::Logger.response format'
    it 'logs an empty body if for some reason I can\'t fathom, the body is nil'
  end

  it 'forwards the app response' do
    app      = mockapp(status: 123, headers: {'the' => 'headers'}, body: ['the body'])
    request  = middleware_request_for(app)
    response = request.get '/whatevz'
    expect(response.status ).to eq 123
    expect(response.headers).to include 'the' => 'headers'
    expect(response.body   ).to eq 'the body'
  end
end

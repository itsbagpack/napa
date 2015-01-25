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
    it 'logs the status headers, and body, according to the Napa::Logger.response format' do
      app      = mockapp(status: 123, headers: {'the' => 'headers'}, body: ['the body', 'the hip bone'])
      request  = middleware_request_for(app)
      response = request.get '/whatevz'
      expect(debug_logged).to eq Napa::Logger.response(123, {'the' => 'headers'}, ['the body', 'the hip bone'])
    end
    it 'logs the body as an array, regardless of what it was initially given' do
      body = Object.new
      def body.each; yield "a"; yield "b"; yield "c"; nil end
      app      = mockapp body: body
      response = middleware_request_for(app).get('/')
      expect(debug_logged[:response][:response]).to eq ['a', 'b', 'c']
    end
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

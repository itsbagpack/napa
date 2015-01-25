require 'napa/param_sanitizer'

module Napa
  class Middleware
    class Logger
      include Napa::ParamSanitizer

      def initialize(app)
        @app = app
      end

      def call(env)
        # log the request
        Napa::Logger.logger.info format_request(env)

        # process the request
        status, headers, body = @app.call(env)

        # log the response
        Napa::Logger.logger.debug format_response(status, headers, body)

        # return the results
        [status, headers, body]
      ensure
        # Clear the transaction id after each request
        Napa::LogTransaction.clear
      end

      private

        def format_request(env)
          request = Rack::Request.new(env)
          params  = request.params

          begin
            params = JSON.parse(request.body.read) if env['CONTENT_TYPE'] == 'application/json'
          rescue
            # do nothing, params is already set
          end

          request_data = {
            method:           request.request_method,
            path:             request.path_info,
            query:            filtered_query_string(request.query_string),
            host:             Napa::Identity.hostname,
            pid:              Napa::Identity.pid,
            revision:         Napa::Identity.revision,
            params:           filtered_parameters(params),
            remote_ip:        request.ip
          }
          request_data[:user_id] = current_user.try(:id) if defined?(current_user)
          { request: request_data }
        end

        def format_response(status, headers, body)
          response_body = []
          body.each { |r| response_body << r } # rack only specifies the body responds to #each
          Napa::Logger.response(status, headers, response_body)
        end
    end
  end
end

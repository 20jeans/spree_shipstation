module Spree
  module BasicSslAuthentication
    extend ActiveSupport::Concern

    included do
      ssl_required
      before_filter :authenticate
    end

    def logger
      @_logger ||= Logger.new(Rails.root + 'log/shipfuckingstation.log')
    end

    protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        logger.info "#{username}:#{password}"
        username == Spree::Config.shipstation_username && password == Spree::Config.shipstation_password
      end
    end
  end
end
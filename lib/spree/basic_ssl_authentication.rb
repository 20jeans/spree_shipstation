module Spree
  module BasicSslAuthentication
    extend ActiveSupport::Concern

    included do
      ssl_required
      before_filter :authenticate
    end

    protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        puts "username: expected #{Spree::Config.shipstation_username}, got #{username}"
        puts "username: expected #{Spree::Config.shipstation_password}, got #{password}"
        username == Spree::Config.shipstation_username && password == Spree::Config.shipstation_password
      end
    end
  end
end
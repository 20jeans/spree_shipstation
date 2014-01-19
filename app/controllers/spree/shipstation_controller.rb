module Spree
  class ShipstationController < ApplicationController
    include Spree::DateParamHelper

    ssl_required
    before_filter :authenticate_shipstation

    skip_before_filter :verify_authenticity_token, only: :shipnotify

    def export
      @shipments = Spree::Shipment.exportable
                           .between(date_param(:start_date), date_param(:end_date))
                           .page(params[:page])
                           .per(50)
      render layout: false
    end

    def shipnotify
      notice = Spree::ShipmentNotice.new(params)

      if notice.apply
        render(text: 'success')
      else
        Rails.logger.error("SHIPNOTIFY_ERROR: " + error)
        render(text: notice.error, status: :bad_request)
      end
    end

    def logger
      @_logger ||= Logger.new(Rails.root + 'log/shipfuckingstation.log')
    end

    protected

    def authenticate_shipstation
      authenticate_or_request_with_http_basic do |username, password|
        logger.info "#{username}:#{password}"
        username == Spree::Config.shipstation_username && password == Spree::Config.shipstation_password
      end
    end
  end
end
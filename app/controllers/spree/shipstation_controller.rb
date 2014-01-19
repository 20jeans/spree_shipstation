module Spree
  class ShipstationController < ActionController::Base
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
        logger.error("SHIPNOTIFY_ERROR: " + error)
        render(text: notice.error, status: :bad_request)
      end
    end

    def logger
      @_logger ||= Logger.new(Rails.root + 'log/shipfuckingstation.log')
    end

    protected

    def authenticate_shipstation
      logger.info "AUTH: #{request.headers['HTTP_AUTHORIZATION']}"
      authenticate_or_request_with_http_basic do |username, password|
        logger.info "#{username}:#{password}"
        username == Spree::Config.shipstation_username && password == Spree::Config.shipstation_password
      end
    end

    def date_param(name)
      Time.strptime(params[name] + " UTC", "%m/%d/%Y %H:%M %Z")
    end
  end
end
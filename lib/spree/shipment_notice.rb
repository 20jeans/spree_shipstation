module Spree
  class ShipmentNotice
    attr_reader :error

    def initialize(params)
      @number   = params[:order_number]
      @tracking = params[:tracking_number]
    end

    def apply
      locate ? update : not_found
    end

  private
    def locate
      @shipment = if Spree::Config.shipstation_number == :order
        Spree::Order.where(number: @number).first.try(:shipment)
      else
        Spree::Shipment.where(number: @number).first
      end
    end

    def update
      @shipment.update_attribute(:tracking, @tracking)

      unless @shipment.shipped?
        @shipment.reload.update_attribute(:state, 'shipped')
        @shipment.inventory_units.each(&:ship!)
        @shipment.touch(:shipped_at)
      end

      true
    end

    def not_found
      @error = I18n.t(:shipment_not_found, number: @number)
      false
    end

    def handle_error(error)
      Rails.logger.error(error)
      @error = I18n.t(:import_tracking_error, error: error.to_s)
      false
    end
  end
end
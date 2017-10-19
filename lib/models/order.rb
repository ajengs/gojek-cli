# order.rb
require 'json'

module GoCLI
  # Order class
  class Order
    attr_accessor :timestamp, :origin, :destination, :est_price
    attr_accessor :origin_name, :destination_name, :type

    def initialize(opts = {})
      @timestamp = opts[:timestamp] || Time.now
      @origin = opts[:origin].coord
      @destination = opts[:destination].coord
      @origin_name = opts[:origin].name
      @destination_name = opts[:destination].name
      @type = opts[:type]
      @price_per_km = @type == 'bike' ? 1_500 : 2_500
      @est_price = opts[:est_price] || calculate_est_price
    end

    def self.load_all
      return nil unless File.file?("#{Dir.pwd}/data/orders.json")

      file = File.read("#{Dir.pwd}/data/orders.json")
      data = JSON.parse(file)
      order_all = []
      data.each do |o|
        order_all << new(
            timestamp: o['timestamp'],
            origin: Location.new(name: o['origin']),
            destination: Location.new(name: o['destination']),
            est_price: o['est_price'],
            type: o['type']
        )
      end
      order_all
    end

    def save!
      data = []
      if File.file?("#{Dir.pwd}/data/orders.json")
        file = File.read("#{Dir.pwd}/data/orders.json")
        data = JSON.parse(file)
      end

      data << {
        timestamp: @timestamp,
        origin: @origin_name,
        destination: @destination_name,
        est_price: @est_price,
        type: @type
      }
      File.open("#{Dir.pwd}/data/orders.json", 'w') do |f|
        f.write JSON.pretty_generate(data)
      end
    end

  protected

    def calculate_est_price
      est_price = Location.calculate_distance(@origin, @destination) * @price_per_km
      est_price.round
    end
  end
end

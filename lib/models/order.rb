# order.rb
require 'json'

module GoCLI
  # Order class
  class Order
    attr_accessor :timestamp, :origin, :destination, :est_price
    attr_accessor :type, :discount # :origin_name, :destination_name, 

    def initialize(opts = {})
      @timestamp = opts[:timestamp] || Time.now
      @origin = opts[:origin]# .coord
      @destination = opts[:destination] # .coord
      # @origin_name = opts[:origin].name
      # @destination_name = opts[:destination].name
      @type = opts[:type]
      @price_per_km = @type == 'bike' ? 1_500 : 2_500
      @discount = opts[:discount]
      @est_price = opts[:est_price] || (calculate_est_price - @discount < 0 ? 0 : calculate_est_price)
    end

    def self.load_all
      order_all = []
      return order_all unless File.file?("#{Dir.pwd}/data/orders.json")

      file = File.read("#{Dir.pwd}/data/orders.json")
      data = JSON.parse(file)
      
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
        origin: @origin.name,
        destination: @destination.name,
        est_price: @est_price,
        type: @type
      }
      File.open("#{Dir.pwd}/data/orders.json", 'w') do |f|
        f.write JSON.pretty_generate(data)
      end
    end

    def self.promo(code)
      disc = 0
      return disc unless File.file?("#{Dir.pwd}/data/promo.json")
      
      file = File.read("#{Dir.pwd}/data/promo.json")
      data = JSON.parse(file)
      
      data.each do |o|
        if o['code'] == code.downcase
          disc = o['discount']
          break
        end
      end
      disc
    end

  protected

    def calculate_est_price
      est_price = Location.calculate_distance(@origin.coord, @destination.coord) * @price_per_km
      est_price.round
    end
  end
end

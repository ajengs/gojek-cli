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
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
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
      if File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
        file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
        data = JSON.parse(file)
      end

      data << {
        timestamp: @timestamp,
        origin: @origin_name,
        destination: @destination_name,
        est_price: @est_price,
        type: @type
      }
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json", 'w') do |f|
        f.write JSON.pretty_generate(data)
      end
    end

    def find_driver
      designated = {}

      return designated unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")
      data = JSON.parse(file)
      nearest_driver = 1.0
      choosen = nil

      data.each_with_index do |driver, i|
        distance = calculate_distance(@origin, driver['coord'])
        next unless distance <= nearest_driver && driver['type'] == @type
        nearest_driver = distance
        designated[:driver] = driver['driver']
        designated[:coord] = driver['coord']
        designated[:type] = driver['type']
        choosen = i
      end

      unless choosen.is_a?(NilClass)
        data[choosen] = designated
        data[choosen][:coord] = @destination
        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json", 'w') do |f|
          f.write JSON.pretty_generate(data)
        end
      end

      designated
    end

  protected

    def calculate_distance(origin, destination)
      Math.sqrt(((destination[0] - origin[0])**2 +
                (destination[1] - origin[1])**2).to_f)
    end

    def calculate_est_price
      est_price = calculate_distance(@origin, @destination) * @price_per_km
      est_price.round
    end
  end
end

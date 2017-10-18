require 'json'

module GoCLI
  class Order
    attr_accessor :origin, :destination, :fare, :origin_name, :destination_name

    def initialize(opts = {})
      @origin = opts[:origin]
      @destination = opts[:destination]
      @origin_name = opts[:origin_name]
      @destination_name = opts[:destination_name]
      @fare = calculate_fare
    end

    def find_driver
      designated = {}

      return designated unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json")
      data = JSON.parse(file)
      nearest_driver = 1.0
      choosen = nil

      data.each_with_index do |driver, i|
        distance = calculate_distance(@origin, driver["coord"])
        if distance <= nearest_driver
          nearest_driver = distance 
          designated = driver
          choosen = i
        end
      end

      if !choosen.is_a?(NilClass)
        data[choosen] = designated
        data[choosen]['coord'] = @destination
        File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/fleet_loc.json", "w") do |f|
          f.write JSON.generate(data)
        end
      end

      designated
    end
    
    def save!
      data = []
      if File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
        file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
        data = JSON.parse(file)
      end

      data << {timestamp: Time.now, origin: @origin_name, destination: @destination_name, est_price: @fare}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json", "w") do |f|
        f.write JSON.generate(data)
      end
    end

    def self.load
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/orders.json")
      data = JSON.parse(file)

      data
    end
    
  protected
    def calculate_distance(origin, destination)
      Math.sqrt(((destination[0] - origin[0])**2 + 
                (destination[1] - origin[1])**2).to_f)
    end

    def calculate_fare
      calculate_distance(@origin, @destination) * 1_500
    end 
  end
end

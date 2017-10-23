require 'json'

module GoCLI
  # class driver
  class Driver
    attr_accessor :driver, :coord, :type

    def initialize(opts = {})
      @driver = opts[:driver] || ''
      @coord = opts[:coord] || []
      @type = opts[:type] || ''
    end

    def self.load_all
      fleet = []
      return fleet unless File.file?("#{Dir.pwd}/data/fleet_loc.json")
      file = File.read("#{Dir.pwd}/data/fleet_loc.json")
      data = JSON.parse(file)
      data.each do |d|
        fleet << new(
            driver: d['driver'],
            coord: d['coord'],
            type: d['type']
        )
      end
      fleet
    end

    def self.find(order)
      data = load_all
      designated = new
      nearest_driver = 1.0

      data.each do |driver|
        distance = Location.calculate_distance(order.origin.coord, driver.coord)
        next unless distance <= nearest_driver && driver.type == order.type
        nearest_driver = distance
        designated = driver
      end

      designated
    end

    def save!
      file = File.read("#{Dir.pwd}/data/fleet_loc.json")
      data = JSON.parse(file)

      data.each do |fleet|
        if fleet['driver'] == @driver && fleet['type'] == @type
          fleet['coord'] = @coord
          break
        end
      end

      File.open("#{Dir.pwd}/data/fleet_loc.json", 'w') do |f|
        f.write JSON.pretty_generate(data)
      end
    end
  end
end

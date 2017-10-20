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

    def self.find(opts = {})
      designated = new
      return designated unless File.file?("#{Dir.pwd}/data/fleet_loc.json")
      order = opts[:order]
      file = File.read("#{Dir.pwd}/data/fleet_loc.json")
      data = JSON.parse(file)
      nearest_driver = 1.0

      data.each do |driver|
        distance = Location.calculate_distance(order.origin, driver['coord'])
        next unless distance <= nearest_driver && driver['type'] == order.type
        nearest_driver = distance
        designated.driver = driver['driver']
        designated.coord = driver['coord']
        designated.type = driver['type']
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

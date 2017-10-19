# location.rb
require 'json'

module GoCLI
  # Location class
  class Location
    attr_accessor :name, :coord

    def initialize(opts = {})
      @name = opts[:name] || ''
      @coord = opts[:coord] || []
    end

    def self.load_all
      locs = []
      return locs unless File.file?("#{Dir.pwd}/data/locations.json")

      file = File.read("#{Dir.pwd}/data/locations.json")
      data = JSON.parse(file)
      
      data.each do |l|
        locs << new(
          name:  l['name'],
          coord: l['coord']
        )
      end
      locs
    end

    def self.find(location_name)
      locations = load_all
      coordinate = self.new
      locations.each do |loc|
        if loc.name == location_name.downcase
          coordinate.coord = loc.coord
          coordinate.name = loc.name
          return coordinate
        end
      end
      coordinate
    end

    def self.calculate_distance(origin, destination)
      Math.sqrt(((destination[0] - origin[0])**2 +
                (destination[1] - origin[1])**2).to_f)
    end
  end
end

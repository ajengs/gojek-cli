# location.rb
require 'json'

# Location class
module GoCLI
  class Location
    attr_accessor :name, :coord

    def initialize(opts = {})
      @name = opts[:name]
      @coord = opts[:coord]
    end

    def self.load_all
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")
      data = JSON.parse(file)
      locs = []
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
      coordinate = []
      locations.each do |loc|
        if loc.name == location_name.downcase
          coordinate = loc.coord
          return coordinate
        end
      end
      coordinate
    end
  end
end

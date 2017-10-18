require 'json'

module GoCLI
  class Location
    def self.load
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/locations.json")
      data = JSON.parse(file)

      data
    end
  end
end



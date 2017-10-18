require 'json'

module GoCLI
  class User
    attr_accessor :phone, :password

    # TODO: 
    # 1. Add two instance variables: name and email 
    # 2. Write all necessary changes, including in other files
    def initialize(opts = {})
      @phone = opts[:phone] || ''
      @password = opts[:password] || ''
    end

    def self.load
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      data = JSON.parse(file)

      self.new(
        phone:    data['phone'],
        password: data['password']
      )
    end

    # TODO: Add your validation method here
    def validate
    end

    def save!
      # TODO: Add validation before writing user data to file
      user = {phone: @phone, password: @password}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json", "w") do |f|
        f.write JSON.generate(user)
      end
    end
  end
end

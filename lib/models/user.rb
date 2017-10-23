# user.rb
require 'json'

module GoCLI
  # User class
  class User
    attr_accessor :phone, :password, :name, :email, :gopay

    def initialize(opts = {})
      @phone = opts[:phone] || ''
      @password = opts[:password] || ''
      @name = opts[:name].downcase || ''
      @email = opts[:email].downcase || ''
      @gopay = opts[:gopay] || 0
    end

    def self.load
      return nil unless File.file?("#{Dir.pwd}/data/user.json")

      file = File.read("#{Dir.pwd}/data/user.json")
      data = JSON.parse(file)

      new(
        name:     data['name'],
        email:    data['email'],
        phone:    data['phone'],
        password: data['password'],
        gopay:    data['gopay']
      )
    end

    def validate
      error = []
      error << 'Please fill all fields' if @name.empty? || @email.empty? || phone.empty? || password.empty?
      error
    end

    def save!
      user = { name: @name, email: @email, phone: @phone, password: @password, gopay: @gopay }
      File.open("#{Dir.pwd}/data/user.json", 'w') do |f|
        f.write JSON.pretty_generate(user)
      end
    end

    def credential_match?(login, password)
      return false unless [@phone, @email].include?(login.downcase)
      return false unless @password == password
      true
    end
  end
end

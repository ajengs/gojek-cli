# user.rb
require 'json'

# User class
module GoCLI
  class User
    attr_accessor :phone, :password, :name, :email

    # TODO: DONE
    # 1. Add two instance variables: name and email
    # 2. Write all necessary changes, including in other files
    def initialize(opts = {})
      @phone = opts[:phone] || ''
      @password = opts[:password] || ''
      @name = opts[:name] || ''
      @email = opts[:email] || ''
    end

    def self.load
      return nil unless File.file?("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")

      file = File.read("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json")
      data = JSON.parse(file)

      new(
        name:     data['name'],
        email:    data['email'],
        phone:    data['phone'],
        password: data['password']
      )
    end

    # TODO: Add your validation method here
    def validate
      error = []
      error << 'Please fill all fields' if @name.empty? || @email.empty? || phone.empty? || password.empty?
      error
    end

    def save!
      # TODO: Add validation before writing user data to file
      user = { name: @name, email: @email, phone: @phone, password: @password }
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../../data/user.json", 'w') do |f|
        f.write JSON.pretty_generate(user)
      end
    end

    # TODO: credential matching with email or phone DONE
    def credential_match?(login, password)
      return false unless [@phone, @email].include?(login)
      return false unless @password == password
      true
    end
  end
end

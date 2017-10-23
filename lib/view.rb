module GoCLI
  # View is a class that show menus and forms to the screen
  class View
    # This is a class method called ".registration"
    # It receives one argument, opts with default value of empty hash
    def self.registration(opts = {})
      form = opts

      puts 'Registration'
      puts ''

      print 'Your name     : '
      form[:name] = gets.chomp

      print 'Your email    : '
      form[:email] = gets.chomp

      print 'Your phone    : '
      form[:phone] = gets.chomp

      print 'Your password : '
      form[:password] = gets.chomp

      form[:steps] << { id: __method__ }

      form
    end

    def self.login(opts = {})
      form = opts

      puts 'Login'
      puts ''

      print 'Enter your login    : '
      form[:login] = gets.chomp

      print 'Enter your password : '
      form[:password] = gets.chomp

      form[:steps] << { id: __method__ }

      form
    end

    def self.main_menu(opts = {})
      form = opts

      puts 'Welcome to Go-CLI!'
      puts ''

      puts 'Main Menu'
      puts '1. View Profile'
      puts '2. Order Go-Ride'
      puts '3. View Order History'
      puts '4. Top-up Go-pay'
      puts '5. Exit'

      print 'Enter your option: '
      form[:steps] << {id: __method__, option: gets.chomp }

      form
    end

    def self.view_profile(opts = {})
      form = opts
      user = form[:user]
      puts 'View Profile'
      puts ''

      # Show user data here
      puts "Name   : #{user.name}"
      puts "Email  : #{user.email}"
      puts "Phone  : #{user.phone}"
      puts "Go-pay : Rp#{user.gopay}"
      puts ''

      puts '1. Edit Profile'
      puts '2. Back'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    # This is invoked if user chooses Edit Profile menu when viewing profile
    def self.edit_profile(opts = {})
      form = opts

      puts 'Edit Profile'
      puts ''

      print 'Your name     : '
      form[:name] = gets.chomp

      print 'Your email    : '
      form[:email] = gets.chomp

      print 'Your phone    : '
      form[:phone] = gets.chomp

      print 'Your password : '
      form[:password] = gets.chomp
      puts ''

      puts '1. Save'
      puts '2. Cancel'
      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    def self.order_goride(opts = {})
      form = opts

      puts 'Go-Ride'
      puts ''

      print 'Your pickup location : '
      form[:origin] = gets.chomp

      print 'Your destination     : '
      form[:destination] = gets.chomp
      
      puts  'Type'
      puts  '1. Bike'
      puts  '2. Car'
      print 'Choose vehicle type  : '
      form[:steps] << { id: __method__, option: gets.chomp }

      print 'Enter promo code     : '
      form[:promo_code] = gets.chomp

      form
    end

    # This is invoked after user finishes inputting data in order_goride method
    def self.order_goride_confirm(opts = {})
      form = opts
      order = form[:order]

      puts 'Confirm order Go-Ride'
      puts ''

      puts "Your pickup location : #{order.origin.name}"
      puts "Your destination     : #{order.destination.name}"
      puts "Vehicle type         : #{order.type}"
      puts "Est. price           : Rp#{order.est_price}"
      puts ''

      puts '1. Order with cash'
      puts '2. Order with Go-pay'
      puts '3. Reset order'
      puts '4. Back to main menu'
      print 'Enter your option: '

      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    def self.order_goride_result(opts = {})
      form = opts

      puts "Order #{form[:result]}"
      puts ''

      puts '1. Re-order'
      puts '2. Back to main menu'
      print 'Enter your option: '

      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    # TODO: Complete view_order_history method
    def self.view_order_history(opts = {})
      form = opts
      order_history = form[:order_history]

      puts 'Order History'
      puts ''
      order_history.each do |order|
        puts "Date/Time   : #{order.timestamp}"
        puts "Pickup      : #{order.origin.name}"
        puts "Destination : #{order.destination.name}"
        puts "Type        : #{order.type}"
        puts "Fare        : Rp#{order.est_price}"
        puts '------------------------------------------'
        puts ''
      end
      puts ''

      puts '1. Back to main menu'
      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    def self.topup_gopay(opts = {})
      form = opts
      puts 'Top Up Go-pay'
      puts ''

      puts "Your Go-pay balance is : Rp#{form[:user].gopay}"
      print 'Top up amount : '
      form[:topup] = gets.chomp.to_i

      puts ''
      puts '1. Top up'
      puts '2. Cancel'
      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end
  end
end

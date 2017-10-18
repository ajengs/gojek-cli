require_relative './models/user'
require_relative './models/order'
require_relative './models/location'
require_relative './view'

module GoCLI
  # Controller is a class that call corresponding models and methods for every action
  class Controller
    # This is an example how to create a registration method for your controller
    def registration(opts = {})
      halt = false
      while !halt
        # First, we clear everything from the screen
        clear_screen(opts)

        # Second, we call our View and its class method called "registration"
        # Take a look at View class to see what this actually does
        form = View.registration(opts)

        # This is the main logic of this method:
        # - passing input form to an instance of User class (named "user")
        # - invoke ".save!" method to user object
        # TODO: enable saving name and email DONE
        user = User.new(
          name:     form[:name],
          email:    form[:email],
          phone:    form[:phone],
          password: form[:password]
        )
        error = user.validate
        if error.empty?
          user.save!
          halt = true
        else
          form[:flash_msg] = error
        end
      end
      # Assigning form[:user] with user object
      form[:user] = user

      # Returning the form
      form
    end
    
    def login(opts = {})
      halt = false
      while !halt
        clear_screen(opts)
        form = View.login(opts)

        # Check if user inputs the correct credentials in the login form
        if credential_match?(form[:user], form[:login], form[:password])
          halt = true
        else
          form[:flash_msg] = "Wrong login or password combination"
        end
      end

      return form
    end
    
    def main_menu(opts = {})
      clear_screen(opts)

      form = View.main_menu(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1
        view_profile(form)
      when 2
        # Step 4.2
        order_goride(form)
      when 3
        # Step 4.3
        view_order_history(form)
      when 4
        exit(true)
      else
        form[:flash_msg] = "Wrong option entered, please retry."
        main_menu(form)
      end
    end
    
    def view_profile(opts = {})
      clear_screen(opts)
      form = View.view_profile(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1.1
        edit_profile(form)
      when 2
        main_menu(form)
      else
        form[:flash_msg] = "Wrong option entered, please retry."
        view_profile(form)
      end
    end

    # TODO: Complete edit_profile method DONE
    # This will be invoked when user choose Edit Profile menu in view_profile screen
    def edit_profile(opts = {})
      clear_screen(opts)

      form = View.edit_profile(opts)

      user = User.new(
          name:     form[:name],
          email:    form[:email],
          phone:    form[:phone],
          password: form[:password]
        )

      case form[:steps].last[:option].to_i
      when 1
        error = user.validate
        if error.empty?
          user.save!
          form[:user] = user
          view_profile(form)
        else
          form[:flash_msg] = error
          edit_profile(form)
        end
      when 2
        view_profile(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        edit_profile(form)
      end
    end

    # TODO: Complete order_goride method
    def order_goride(opts = {})
      clear_screen(opts)

      form = View.order_goride(opts)

      origin = find_location(form[:origin])
      destination = find_location(form[:destination])

      if origin.empty? || destination.empty?
        form[:flash_msg] = 'Sorry, the route you requested is not yet available'
        order_goride(form)
      else
        order = Order.new(
            origin:      origin,
            destination: destination,
            origin_name:      form[:origin],
            destination_name: form[:destination]
          )
        form[:order] = order
        order_goride_confirm(form)
      end
    end

    # TODO: Complete order_goride_confirm method
    # This will be invoked after user finishes inputting data in order_goride method
    def order_goride_confirm(opts = {})
      clear_screen(opts)

      form = View.order_goride_confirm(opts)
      order = form[:order]
      case form[:steps].last[:option].to_i
      when 1
        driver = order.find_driver
        if driver.empty?
          form[:flash_msg] = 'Sorry, it appears all of our drivers are currently not available near your pickup area'
          order_goride(form)
        else
          order.save!
          main_menu(form)
        end
      when 2
        order_goride(form)
      when 3
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride(form)
      end
    end

    def view_order_history(opts = {})
      clear_screen(opts)
      form = opts
      form[:order_history] = Order.load

      form = View.view_order_history(form)
      case form[:steps].last[:option].to_i
      when 1
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride(form)
      end
    end
  protected

    def find_location(location_name)
      locations = Location.load
      coordinate = []
      locations.each do |loc|
        if loc.has_value?(location_name.downcase)
          coordinate = loc['coord']
          return coordinate
        end
      end
      coordinate
    end

    # You don't need to modify this 
    def clear_screen(opts = {})
      Gem.win_platform? ? (system "cls") : (system "clear")
      if opts[:flash_msg]
        puts opts[:flash_msg]
        puts ''
        opts[:flash_msg] = nil
      end
    end

    # TODO: credential matching with email or phone DONE
    def credential_match?(user, login, password)
      return false unless user.phone == login || user.email == login
      return false unless user.password == password
      return true
    end
  end
end

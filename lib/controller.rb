require_relative './models/user'
require_relative './models/order'
require_relative './models/location'
require_relative './view'

module GoCLI
  # Controller is a class that call corresponding models
  # and methods for every action
  class Controller
    # This is an example how to create a registration method for your controller
    def registration(opts = {})
      clear_screen(opts)
      form = View.registration(opts)
      user = User.new(
        name:     form[:name],
        email:    form[:email],
        phone:    form[:phone],
        password: form[:password]
      )
      error = user.validate
      if error.empty?
        user.save!
      else
        form[:flash_msg] = error
        registration(form)
      end

      form[:user] = user
      form
    end
    
    def login(opts = {})
      halt = false
      while !halt
        clear_screen(opts)
        form = View.login(opts)

        if form[:user].credential_match?(form[:login], form[:password])
          halt = true
        else
          form[:flash_msg] = 'Wrong login or password combination'
        end
      end

      form
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
        edit_profile(form)
      when 2
        main_menu(form)
      else
        form[:flash_msg] = "Wrong option entered, please retry."
        view_profile(form)
      end
    end

    # This will be invoked when user choose 
    # Edit Profile menu in view_profile screen
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

    def order_goride(opts = {})
      clear_screen(opts)

      form = View.order_goride(opts)

      origin_coord = Location.find(form[:origin])
      destination_coord = Location.find(form[:destination])

      if origin_coord.empty? || destination_coord.empty?
        form[:flash_msg] = 'Sorry, the route you requested is not yet available'
        order_goride(form)
      else
        origin = Location.new(
            name:  form[:origin],
            coord: origin_coord
          )
        
        destination = Location.new(
            name:  form[:destination],
            coord: destination_coord
          )
        
        order = Order.new(
            origin:      origin,
            destination: destination
          )
        
        form[:order] = order
        order_goride_confirm(form)
      end
    end

    # This will be invoked after user finishes inputting data in order_goride method
    def order_goride_confirm(opts = {})
      clear_screen(opts)

      form = View.order_goride_confirm(opts)
      order = form[:order]
      case form[:steps].last[:option].to_i
      when 1
        driver = order.find_driver
        if driver.empty?
          form[:flash_msg] = "Sorry, there's no driver near your pickup area"
          order_goride(form)
        else
          order.save!
          form[:flash_msg] = "Successfully created order. You are assigned to #{driver[:driver]}"
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
      
      opts[:order_history] = Order.load_all
      form = View.view_order_history(opts)
      case form[:steps].last[:option].to_i
      when 1
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride(form)
      end
    end
  protected
    # You don't need to modify this 
    def clear_screen(opts = {})
      Gem.win_platform? ? (system "cls") : (system "clear")
      if opts[:flash_msg]
        puts opts[:flash_msg]
        puts ''
        opts[:flash_msg] = nil
      end
    end

  end
end

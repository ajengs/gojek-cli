require_relative './models/user'
require_relative './models/order'
require_relative './models/location'
require_relative './models/driver'
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
      until halt
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
        topup_gopay(form)
      when 5
        exit(true)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
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
        form[:flash_msg] = 'Wrong option entered, please retry'
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
        password: form[:password],
        gopay:    form[:user].gopay
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
      case form[:steps].last[:option].to_i
      when 1
        form[:type] = 'bike'
      when 2
        form[:type] = 'car'
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride(form)
      end

      origin = Location.find(form[:origin])
      destination = Location.find(form[:destination])
      discount = Order.promo(form[:promo_code])

      if origin.coord.empty? || destination.coord.empty?
        form[:flash_msg] = 'Sorry, the route you requested is not yet available'
        form[:result] = 'failed'
        order_goride_result(form)
      else
        order = Order.new(
          origin:      origin,
          destination: destination,
          type:        form[:type],
          discount:    discount
        )

        form[:order] = order
        if discount.positive?
          form[:flash_msg] = "Congratulations! You got #{discount} discount from #{form[:promo_code].upcase}"
        elsif !form[:promo_code].empty?
          form[:flash_msg] = "Looks like #{form[:promo_code]} is a not valid promo code"
        end
        order_goride_confirm(form)
      end
    end

    # This will be invoked after user finishes inputting data in order_goride method
    def order_goride_confirm(opts = {})
      clear_screen(opts)

      form = View.order_goride_confirm(opts)
      order = form[:order]
      user = form[:user]

      case form[:steps].last[:option].to_i
      when 1
        if validate_driver(form)[:result] == 'success'
          order.save!
          form[:driver].save!
        end
        order_goride_result(form)
      when 2
        if user.gopay < order.est_price
          form[:flash_msg] = 'Your Go-pay balance is not sufficient. Please top-up first'
          form[:result] = 'failed'
        elsif validate_driver(form)[:result] == 'success'
          order.save!
          user.gopay -= order.est_price
          user.save!
          form[:driver].save!
        end
        order_goride_result(form)
      when 3
        order_goride(form)
      when 4
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride_confirm(form)
      end
    end

    def order_goride_result(opts = {})
      clear_screen(opts)

      form = View.order_goride_result(opts)
      case form[:steps].last[:option].to_i
      when 1
        order_goride(form)
      when 2
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        order_goride_result(form)
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
        view_order_history(form)
      end
    end

    def topup_gopay(opts = {})
      clear_screen(opts)

      form = View.topup_gopay(opts)
      case form[:steps].last[:option].to_i
      when 1
        form[:user].gopay += form[:topup]
        form[:user].save!
        form[:flash_msg] = "Your Go-pay balance is now #{form[:user].gopay}"
        main_menu(form)
      when 2
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry'
        topup_gopay(form)
      end
    end

  protected

    # You don't need to modify this
    def clear_screen(opts = {})
      Gem.win_platform? ? (system 'cls') : (system 'clear')
      return unless opts[:flash_msg]
      puts opts[:flash_msg]
      puts ''
      opts[:flash_msg] = nil
    end

    def validate_driver(opts = {})
      form = opts
      order = form[:order]

      driver_assigned = Driver.find(form)
      if driver_assigned.coord.empty?
        form[:flash_msg] = "Sorry, there's no driver near your pickup area"
        form[:result] = 'failed'
      else
        driver_assigned.coord = order.destination
        form[:flash_msg] = "Successfully created order. You are assigned to #{driver_assigned.driver}"
        form[:result] = 'success'
        form[:driver] = driver_assigned
      end
      form
    end
  end
end

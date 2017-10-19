require_relative './controller'
require_relative './models/user'

module GoCLI
  # App is your main class
  # When you start the program with ./bin/start.sh script, you invoke App.run
  # You don't have to change anything in this file
  class App
    def self.run
      form = { steps: [] }
      controller = Controller.new

      # Step 1
      form[:user] = User.load
      form = controller.registration(form) unless form[:user]

      # Step 2
      form = controller.login(form)

      # Step 3
      form = controller.main_menu(form)

      true
    end
  end
end

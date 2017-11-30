# order.rb
require 'json'
require 'bundler/setup'
require 'rdkafka'

module GoCLI
  # Order class
  class Order
    attr_accessor :timestamp, :origin, :destination, :est_price
    attr_accessor :type, :discount

    def initialize(opts = {})
      @timestamp = opts[:timestamp] || Time.now
      @origin = opts[:origin]
      @destination = opts[:destination]
      @type = opts[:type]
      @price_per_km = @type == 'bike' ? 1_500 : 2_500
      @discount = opts[:discount]
      @est_price = opts[:est_price] || (calculate_est_price - @discount < 0 ? 0 : calculate_est_price)
    end

    def self.load_all
      order_all = []
      return order_all unless File.file?("#{Dir.pwd}/data/orders.json")

      file = File.read("#{Dir.pwd}/data/orders.json")
      data = JSON.parse(file)
      
      data.each do |o|
        order_all << new(
            timestamp: o['timestamp'],
            origin: Location.new(name: o['origin']),
            destination: Location.new(name: o['destination']),
            est_price: o['est_price'],
            type: o['type']
        )
      end
      order_all
    end

    def save!
      data = []
      if File.file?("#{Dir.pwd}/data/orders.json")
        file = File.read("#{Dir.pwd}/data/orders.json")
        data = JSON.parse(file)
      end
      new_order = {
        timestamp: @timestamp,
        origin: @origin.name,
        destination: @destination.name,
        est_price: @est_price,
        type: @type
      }

      data << new_order
      
      File.open("#{Dir.pwd}/data/orders.json", 'w') do |f|
        f.write JSON.pretty_generate(data)
      end
      produce(JSON.pretty_generate(new_order))
    end

    def self.promo(code)
      disc = 0
      return disc unless File.file?("#{Dir.pwd}/data/promo.json")
      
      file = File.read("#{Dir.pwd}/data/promo.json")
      data = JSON.parse(file)
      
      data.each do |o|
        if o['code'] == code.downcase
          disc = o['discount']
          break
        end
      end
      disc
    end

  protected
    def calculate_est_price
      est_price = Location.calculate_distance(@origin.coord, @destination.coord) * @price_per_km
      est_price.round
    end

    def produce(data)
      config = {
                :"bootstrap.servers" => 'velomobile-01.srvs.cloudkafka.com:9094,velomobile-02.srvs.cloudkafka.com:9094,velomobile-03.srvs.cloudkafka.com:9094',
                :"group.id"          => "cloudkarafka-example4",
                :"sasl.username"     => 'xz6befqu',
                :"sasl.password"     => 'ZnTqLiR0WxwLHX_jdiGChcbi4W-H9Mzd',
                :"security.protocol" => "SASL_SSL",
                :"sasl.mechanisms"   => "SCRAM-SHA-256"
      }
      # topic = "#{ENV['CLOUDKARAFKA_TOPIC_PREFIX']}test"
      topic = "xz6befqu-default"

      rdkafka = Rdkafka::Config.new(config)
      time = Time.now.to_s
      producer = rdkafka.producer
      puts "producing #{data}"
      producer.produce(
          topic:   topic,
          payload: data,
          key:     time
      ).wait
    end
  end
end

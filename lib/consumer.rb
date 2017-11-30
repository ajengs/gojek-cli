require 'bundler/setup'
require 'rdkafka'
require 'json'

def load
  data = []
  if File.file?("#{Dir.pwd}/data/consumer_orders.json")
    file = File.read("#{Dir.pwd}/data/consumer_orders.json")
    data = JSON.parse(file)
  end
  data
end

def save(new_order)
  data = load
  data << new_order
  
  File.open("#{Dir.pwd}/data/consumer_orders.json", 'w') do |f|
    f.write JSON.pretty_generate(data)
  end
end

def dashboard
  orders = load
  puts "most expensive ride: #{JSON.pretty_generate(orders.max_by { |o| o['est_price'] })}"
  puts "least expensive ride: #{JSON.pretty_generate(orders.min_by { |o| o['est_price'] })}"
  puts "------------------------------------------------------------"
end

def consume_save_dashboard
  config = {
            :"bootstrap.servers" => 'velomobile-01.srvs.cloudkafka.com:9094,velomobile-02.srvs.cloudkafka.com:9094,velomobile-03.srvs.cloudkafka.com:9094',
            :"group.id"          => "cloudkarafka-example4",
            :"sasl.username"     => 'xz6befqu',
            :"sasl.password"     => 'ZnTqLiR0WxwLHX_jdiGChcbi4W-H9Mzd',
            :"security.protocol" => "SASL_SSL",
            :"sasl.mechanisms"   => "SCRAM-SHA-256"
  }

  topic = "xz6befqu-default"

  rdkafka = Rdkafka::Config.new(config)
  consumer = rdkafka.consumer
  consumer.subscribe(topic)

  begin
    consumer.each do |message|
      puts "Message received: #{message.payload}"
      new_order = JSON.parse(message.payload)
      save(new_order)
      dashboard
    end
  rescue Rdkafka::RdkafkaError => e
    retry if e.is_partition_eof?
    raise
  end
end

consume_save_dashboard
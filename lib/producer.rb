require 'bundler/setup'
require 'rdkafka'

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
producer = rdkafka.producer

100.times do |i|
  puts "Producing message #{i}"
  producer.produce(
      topic:   topic,
      payload: "Payload #{i}",
      key:     "Key #{i}"
  ).wait
end

# frozen_string_literal: true

# Karafka should be able to easily consume and produce messages from consumer

setup_karafka

produce(DataCollector.topic, 0.to_json)

class Consumer < Karafka::BaseConsumer
  def consume
    messages.each do |message|
      next if message.payload > 10

      producer.produce_sync(
        topic: DataCollector.topic,
        payload: (message.payload + 1).to_json
      )

      DataCollector.data[0] << message.payload
    end
  end
end

Karafka::App.routes.draw do
  consumer_group DataCollector.consumer_group do
    topic DataCollector.topic do
      consumer Consumer
    end
  end
end

start_karafka_and_wait_until do
  DataCollector.data[0].size > 10
end

assert_equal (0..10).to_a, DataCollector.data[0]
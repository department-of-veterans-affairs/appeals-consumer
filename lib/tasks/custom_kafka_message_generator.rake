# frozen_string_literal: true

# This allows you to run a custom lib/kafka_message_generators file
# for example: bundle exec rake kafka_message_generators:decision_review_events
namespace :kafka_message_generators do
  Dir[File.join(Rails.root, "lib", "kafka_message_generators", "*.rb")].each do |filename|
    task_name = File.basename(filename, ".rb").intern
    task task_name, [:arg1] => :environment do |t,args|
      load(filename)
      # when bundle exec rake kafka_message_generators:decision_review_created_events is called
      # it runs the publish_messages! method within decision_review_created_events.rb
      class_name = task_name.to_s.camelize
      KafkaMessageGenerators.const_get(class_name).new(args.arg1).publish_messages!
    end
  end
end

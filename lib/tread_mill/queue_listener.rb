# encoding: utf-8

require 'active_job/queue_adapters/sneakers_adapter'

module TreadMill
  # We want to subclass the JobWrapper to ensure the messages are deserialized
  # properly.
  class QueueListener < ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper
    include ActiveSupport::Rescuable

    # Generate a worker for each queue specified.
    def self.for_queues(*queues)
      queues.flatten.map do |queue|
        # Sneakers::Runner wants a worker class, not an instance.
        # So, here we are creating anonymous classes and setting the queue
        # accordingly.
        Class.new(QueueListener) do
          from_queue queue
        end
      end
    end
  end
end
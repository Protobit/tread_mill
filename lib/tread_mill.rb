# encoding: utf-8

# Load sneakers...
require 'sneakers'
require 'sneakers/runner'
require 'active_job'

require 'tread_mill/fork_callbacks'
require 'tread_mill/queue_listener'

# ActiveJob currently sets the queue_name by concatenating with a '_'.
module ActiveJob
  class Base
    def self.queue_as(part_name, base_name = nil)
      # Allow for classes to override global base_name
      base_name ||= queue_base_name

      self.queue_name = "#{base_name}#{part_name}"
    end
  end
end

module TreadMill
  include ActiveSupport::Configurable

  config_accessor :queues, :workers, :pid_path

  # Check to see if we're properly configured to send messages.
  def self.configured?
    Sneakers.configured? &&
      !Sneakers::Config[:amqp]
        .match(/^amqps?:\/\/([^:]+(:[^@]+)?@)?[^:]+(:[0-9]+)?\/?$/).nil?
  end

  # Process input queues to ensure QueueListener#for_queues gets the proper
  # input.
  def self.process_queues(queues)
    case queues
    when Array
      queues.flatten
    when String
      queues.split(',')
    else
      fail ArgumentError, 'TreadMill#run_queues must be passed an Array of '\
        'queues or comma separated list of queues.'
    end
  end

  mattr_accessor :runner

  # Setup QueueListeners for each queue and run them in a Sneakers::Runner.
  # Take the passed in queues first if provided, then use any application
  # configured queues.
  def self.run_queues(ques = nil, options = {})
    ques = self.process_queues(ques) if ques
    queue_listeners = QueueListener.for_queues(ques || queues)

    sneakers_config = {
      before_fork: ForkCallbacks.method(:before_fork),
      after_fork: ForkCallbacks.method(:after_fork)
    }

    # Let these primarily reside in the sneakers config unless explicitly set.
    sneakers_config[:workers] = workers if workers
    sneakers_config[:pid_path] = pid_path if pid_path

    Sneakers.configure(sneakers_config.merge(options))

    self.runner = Sneakers::Runner.new(queue_listeners)
    self.runner.run
  end

  # If a runner is running, stop it.
  def self.stop_queues
    self.runner.stop unless self.runner.nil?
  end
end

require 'tread_mill/railtie' if defined?(Rails)
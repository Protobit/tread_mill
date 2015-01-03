# encoding: utf-8

# Load sneakers...
require 'sneakers'
require 'sneakers/runner'

require 'tread_mill/fork_callbacks'
require 'tread_mill/queue_listener'

module TreadMill
  include ActiveSupport::Configurable

  config_accessor :queues, :workers

  # Check to see if we're properly configured to send messages.
  # Unfortunately, sneakers/bunny doesn't have a real method check because
  # the connections are setup at request time.  This is really just a best
  # guess.
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
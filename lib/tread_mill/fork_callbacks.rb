# encoding: utf-8

module TreadMill
  # Encapsulate before and after fork collbacks.

  module ForkCallbacks
    def self.before_fork
      # as there's no need for the master process to hold a connection
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.connection.disconnect!
      end
    end

    def self.after_fork
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.establish_connection
      end
    end
  end
end
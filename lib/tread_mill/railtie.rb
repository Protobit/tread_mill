# encoding: utf-8

module TreadMill
  class Railtie < Rails::Railtie
    railtie_name :tread_mill

    config.tread_mill = ActiveSupport::OrderedOptions.new

    rake_tasks do
      load "tasks/tread_mill_tasks.rake"
    end

    initializer "tread_mill.set_configs" do |app|
      options = app.config.tread_mill
      options.queues ||= []

      ActiveSupport.on_load(:tread_mill) do
        options.each { |k,v| send("#{k}=", v) }
      end

      ActiveJob::Base.queue_adapter = :sneakers
    end
  end
end

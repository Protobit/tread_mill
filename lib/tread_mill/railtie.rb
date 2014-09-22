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
      options.each { |k,v| TreadMill.send("#{k}=", v.flatten) }
    end
  end
end

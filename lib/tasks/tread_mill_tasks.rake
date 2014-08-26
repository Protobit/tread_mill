require 'tread_mill'

namespace :tread_mill do
  desc 'Run ActiveJob workers against environment specified queues.'
  task run: :environment do
    TreadMill.run_queues(ENV['QUEUE'] || ENV['QUEUES'])
  end
end
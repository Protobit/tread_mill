tread_mill
==========

TreadMill Rails plugin for background workers.  This gem is designed to integrate into an existing Rails application and provide immediate RabbitMQ integration using the Sneakers worker gem and Rails 4.1+ ActiveJob.

**NOTE:** ActiveJob from RubyGems is a relatively old version.  For my production application, until we bump to Rails 4.2, we're using HEAD on the rails/ActiveJob *archive* branch.

**As of this writing, this gem has not been published, but it can be accessed via bundler using git.**

**Choose your ref HEAD wisely.**

## Options

```RUBY
module MyApp
  class Application < Rails::Application
    # Queues you wish to listen on.
    config.tread_mill.queues = %w(amqp.myapplication.my_queue amqp.myapplication.my_second_queue)

    # Optional: Probably best set in your sneakers configuration.
    # config.tread_mill.workers = # of workers
    # config.tread_mill.pid_path = '../path/pids/sneakers.pid'
  end
end
```

## Running your ActiveJob based workers.

```
rake tread_mill:run
```

**That's it.**

Assuming you are using the ActiveJob::Base worker class:

```Ruby
# app/workers/my_worker.rb

class Workers::MyWorker < ActiveJob::Base
  queue_as :my_queue

  def perform(user)
    user.do_work
  end

  class << self
    def work_for(user)
      self.enqueue(user)
    end
  end
end
```

And you've set your base name:

```Ruby
# config/initializers/active_job.rb

ActiveJob::Base.queue_base_name = 'amqp.myapplication.'

# ActiveJob::Base.queue_adapter is handled by TreadMill automatically.
# ActiveJob::Base.queue_adapter = :sneakers 
```

Then you are set to use your workers wherever you want:

```Ruby
# app/models/user.rb

class User
  def work_later
    Workers::MyWorker.work_for(self)
  end
end
```

# TreadMill

TreadMill Rails plugin for background workers.  This gem is designed to integrate into an existing Rails application and provide immediate RabbitMQ integration using the Sneakers worker gem and Rails 4.2 ActiveJob.

**As of this writing, this gem has not been published, but it can be accessed via bundler using git.**

**Use the [0.0.1](/Protobit/tread_mill/wiki/0.0.1) tag for Rails 4.1  and `0.0.2` tag for Rails 4.2+**

## Installation

Add this line to your applications's Gemfile:

```
gem 'tread_mill', git: 'https://github.com/Protobit/tread_mill', tag: '0.0.2'
```

And then execute:

```
bundle install
```

## Usage

### Options

```RUBY
module MyApp
  class Application < Rails::Application
    # Queues you wish to listen on.
    config.tread_mill.queues = %w(amqp.myapplication.my_queue amqp.myapplication.my_second_queue)
    config.active_job.queue_adapter = :sneakers

    # Configure 'ActionMailer#deliver_later'
    config.tread_mill.queues << 'amqp.myapplication.mailers'

    # Optional: Probably best set in your sneakers configuration.
    # config.tread_mill.workers = # of workers
    # config.tread_mill.pid_path = '../path/pids/sneakers.pid'

    config.active_job.queue_base_name = 'amqp.myapplication'
  end
end
```

`ActiveJob::Base#queue_name_prefix` is prepended with an underscore ('_') for
whatever reason. If, like our dev team, you use the AMQP style queue names
separated by '.' then set the `app.config.queue_name_prefix` to `nil` and use
the full queue name in `ActiveJob::Base#queue_as(queue)`.

Additionally, for `ActionMailer::DeliverLater`, you'll need to pass in an
optional argument to set the queue:

```RUBY
MyMailer.deliver_later(queue: 'amqp.myapplicat.mailer')
```

### Running your ActiveJob based workers.

```
rake tread_mill:run
```

**That's it.**

### Example workers:


Assuming you are using the ActiveJob::Base worker class:

```Ruby
# app/workers/my_worker.rb

class Workers::MyWorker < ActiveJob::Base
  queue_as :my_queue # queue used will be 'amqp.myapplication_my_queue'

  # If you use decimals or some other non-underscore join:
  # queue_as 'amqp.myapplication.my_queue'

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

Then you are set to use your workers wherever you want:

```Ruby
# app/models/user.rb

class User
  def work_later
    Workers::MyWorker.work_for(self)
  end
end
```

### Support Versions

#### Rail 4.2

TreadMill should work out of the box with a valid Sneakers configuration. For ActionMailer::DeliverLater integration, all you need to do is include a `:mailer` queue, which should be prefixed by your selected `queue_name_prefix` (`config.tread_mill.queues = %(amqp.myapplication.mailers)`).

#### Rails <=4.1

Due to a pretty large set of API changes between ActiveJob's github repository pre-merge and now, it doesn't make sense to support pre-4.2 ActiveJob, especially considering the Rails team has flatly rejected supporting pre-4.2.  As a result, this gem as of version `0.0.2`, only supports `>= 4.2.0.beta1`.

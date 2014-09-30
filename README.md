# TreadMill

TreadMill Rails plugin for background workers.  This gem is designed to integrate into an existing Rails application and provide immediate RabbitMQ integration using the Sneakers worker gem and Rails 4.2.0.beta1 ActiveJob.

**As of this writing, this gem has not been published, but it can be accessed via bundler using git.**

**Use the [0.0.1](/Protobit/tread_mill/wiki/0.0.1) tag for Rails 4.1  and `0.0.2` tag for Rails 4.2.0.beta1**

**Untested with 4.2.0.beta2; please create an issue if you see any!**

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

    config.active_job.queue_base_name = 'amqp.myapplication'
  end
end
```

**Note: I've submitted a PR to the Rails team to make the prefix configurable.  [Rails PR #17039 for more details.](See https://github.com/rails/rails/pull/17039)**

`ActiveJob::Base#queue_name_prefix` is prepended with an underscore ('_') for
whatever reason. If, like our dev team, you use the AMQP style queue names
separated by '.' then set the `app.config.queue_name_prefix` to `nil` and use
the full queue name in `ActiveJob::Base#queue_as(queue)`.

Alternately, use `self.queue_name = 'full.queue.name'`, but this won't work in
Rails 4.2.0.beta2, which has some pretty hefty re-writes to the ActiveJob API.

Additionally, for `ActionMailer::DeliverLater`, this is unsupported in Rails
4.2.0.beta1.

If using Rails 4.2.0.beta2, you can try to pass in an optional argument to set
the queue:

```RUBY
MyMailer.deliver_later(queue: 'amqp.myapplicat.mailer')
```

But this gem hasn't been tested with Rails 4.2.0.beta2 yet.

### Running your ActiveJob based workers.

```
rake tread_mill:run
```

**That's it.**

### Example Upstart:

As suggested by jondot, the Sneakers maintainer, daemons used to run jobs with
Sneakers, and thusly TreadMill, should be done so using Upstart, or any other
of the many management subsystems.  Sneakers no longer supports the ability to
daemonize.

The following a sample upstart config file to get you started:

```
description 'Application Tread Mill Server'

env ENVIRONMENT_VAR='VALUE'

setuid deploy
setgid www-data

chdir /srv/www/application/current

start on [2345]
stop on [!2345]

exec /usr/local/bin/ruby /usr/local/bin/bundle exec rake tread_mill:run
```

This file will go in `/etc/init` on Ubuntu systems.  Should be named with the 
service name followed by `.conf`: `application-treadmill.conf`.

Now to start/stop your service:

```BASH
root@nix:/root# start application-treadmill
application-treadmill start/running, process 27996
...
root@nix:/root# stop application-treadmill
application-treadmill stop/waiting
```

More information on Upstart can be found [here](http://upstart.ubuntu.com/cookbook/#console).

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

#### Rails 4.2.0.beta2

I haven't had a chance to test out TreadMill with Rails 4.2.0.beta2.  It may or
may not work as is.  If there are any issues, feel free to take a stab and
submit a PR.  The likely culprit will be in [the QueueListener class](/Protobit/tread_mill/blob/master/lib/tread_mill/queue_listener.rb)
since it is the shim between `Sneakers` and `ActiveJob`.

#### Rails 4.2.0.beta1

TreadMill should work out of the box with a valid Sneakers configuration. For ActionMailer::DeliverLater integration, all you need to do is include a `:mailer` queue, which should be prefixed by your selected `queue_name_prefix` (`config.tread_mill.queues = %(amqp.myapplication.mailers)`).

#### Rails <=4.1

Due to a pretty large set of API changes between ActiveJob's github repository pre-merge and now, it doesn't make sense to support pre-4.2 ActiveJob, especially considering the Rails team has flatly rejected supporting pre-4.2.  As a result, this gem as of version `0.0.2`, only supports `>= 4.2.0.beta1`.

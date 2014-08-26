# TreadMill

TreadMill Rails plugin for background workers.  This gem is designed to integrate into an existing Rails application and provide immediate RabbitMQ integration using the Sneakers worker gem and Rails 4.1+ ActiveJob.

**NOTE:** ActiveJob from RubyGems is a relatively old version.  For my production application, until we bump to Rails 4.2, we're using HEAD on the rails/ActiveJob *archive* branch.

**As of this writing, this gem has not been published, but it can be accessed via bundler using git.**

**Choose your ref HEAD wisely.**

## Installation

Add this line to your applications's Gemfile:

```
gem 'tread_mill', git: 'https://github.com/Protobit/tread_mill'
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

    # Configure 'ActionMailer#deliver_later'
    config.tread_mill.queues << 'amqp.myapplication.mailers'

    # Optional: Probably best set in your sneakers configuration.
    # config.tread_mill.workers = # of workers
    # config.tread_mill.pid_path = '../path/pids/sneakers.pid'
  end
end
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

### Support Versions

#### Rail 4.2

TreadMill should work out of the box with a valid Sneakers configuration. For ActionMailer::DeliverLater integration, all you need to do is include a `:mailer` queue, which should be prefixed by your selected `queue_base_name` (`config.tread_mill.queues = %(amqp.myapplication.mailers)`).

#### Rails 4.1

TreadMill requires ActiveJob.  TreadMill currently depends on ActiveJob, but RubyGems carries a relatively early version of ActiveJob, so your best bet is installing it from [this](http://github.com/rails/activejob) repository, specifically the `archive` branch.

If you want to use ActionMailer::DeliverLater, the pre-merge Github repository for the ActionMailer::DeliverLater feature can be found [here](http://github.com/seuros/actionmailer-deliver_later).  This repository may at some point in the future be updated to work with Rails 4.1.  Currently, however, there is a bug in how it overrides ActionMailer's `missing_method` functionality.  I have forked this branch for use specifically with Rails 4.1 and applied necessary patches (see the repos readme for details) to get it working.  Instructions on usage and installation can be found [here](http://github.com/Protobit/actionmailer-deliver_later).

#### Rails <4.1

At this time, I have not tested TreadMill, ActiveJob, or ActionMailer::DeliverLater on any configuration below Rails 4.1.5.  If you wish to, and you find any issues, please feel free to fix them and roll a Pull Request.
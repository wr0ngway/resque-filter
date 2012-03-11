A resque plugin that allows jobs to to determine if they get run.  For example, one can author jobs that are filter-aware so that they can be scheduled with resque-scheduler to run on specific hosts.

Authored against Resque 1.20.0, so it at least works with that - try running the tests if you use a different version of resque

Usage:

Install the gem, then define a worker with a filter method.  If that method returns true, the job will run, otherwise it will get re-enqueued.

    class MyFilteredWorker
    
      def self.perform(*args)
        puts "I ran"
      end
      
      def self.filter(*args)
        return `hostname`.chomp == args.first
      end
      
    end


You can also configure an alternate queue management strategy like so:

    Resque::Plugins::Filter::JobFilter.configure do |config|
      # The queue strategy to use when filtering job:
      #   :simple - pops, checks filter, pushes if not runnable
      #   :optimistic - peeks, checks filter, pops if runnable (not distributed client safe)
      config.strategy = :simple
    end

Contributors:

Matt Conway ( https://github.com/wr0ngway )

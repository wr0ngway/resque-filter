require 'resque/worker'

# To configure resque filter, add something like the
# following to an initializer (defaults shown):
#
#    Resque::Plugins::Filter::JobFilter.configure do |config|
#      # The queue strategy to use when filtering job:
#      #   :simple - pops, checks filter, pushes if not runnable
#      #   :optimistic - peeks, checks filter, pops if runnable (not distributed client safe)
#      config.strategy = :simple
#    end
module Resque
  module Plugins
    module Filter

      module JobFilter
        
        # Allows configuring via class accessors
        class << self
          # optional
          attr_accessor :strategy
          
          def strategy=(s)
            raise "Invalid strategy: #{s}" unless [:simple, :optimistic].include?(s)
            @strategy = s
          end
        end
  
        # default values
        self.strategy = :simple
  
        # Allows configuring via class accessors
        def self.configure
          yield self
        end
      
        def self.extended(receiver)
           class << receiver
             alias reserve_without_filter reserve
             alias reserve reserve_with_filter
           end
        end

        def reserve_with_filter(queue)
          send("#{JobFilter.strategy}_reserve_with_filter", queue)
        end
        
        def simple_reserve_with_filter(queue)
          return unless job = reserve_without_filter(queue)
          
          # if the class participates in filter, and doesn't want to be run,
          # then push it back onto queue
          if filter(job)
            return job
          else
            Resque.push(queue, job.payload)
            return nil
          end
        end

        # if filtering on hostname, in a cluster of many workers, it could
        # take a while for the job to get to the machine in question as unrelated
        # workers would thrash on this job, thereby preventing it from reaching
        # the right worker.  By peeking at the data and only popping it if filtered,
        # then the right worker would get the job quicker.  However, if there are
        # other jobs on the queue, it may still take a while.  This is also not
        # DistributedRedis client safe due to the use of watch/multi/exec
        #
        def optimistic_reserve_with_filter(queue)
          # http://redis.io/topics/transactions
          # WATCH mykey
          # val = GET mykey
          # val = val + 1
          # MULTI
          # SET mykey $val
          # EXEC
          
          key = "queue:#{queue}"
          redis.watch(key)
            
          return unless payload = decode(redis.lindex(key, 0))
          
          job = new(queue, payload)
          
          if filter(job)
            success = redis.multi do
              redis.lpop(key)
            end
            return job if success
          end
          
          return nil
        end
        
        def filter(job)
          if job.payload_class.respond_to?(:filter)
            return job.payload_class.filter(*job.args)
          else
            return true
          end
        end

      end

    end
  end
end

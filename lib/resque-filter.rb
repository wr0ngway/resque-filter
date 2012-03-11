require 'resque'
require 'resque/job'
require 'resque/plugins/filter/version'
require 'resque/plugins/filter/job_filter'

Resque::Job.send(:extend, Resque::Plugins::Filter::JobFilter)

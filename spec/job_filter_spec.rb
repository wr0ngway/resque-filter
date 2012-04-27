require "spec_helper"

describe "Resque Job Filter" do

  before(:each) do
    Resque.redis.flushall
  end

  after(:each) do
    Resque.redis.lrange("failed", 0, -1).size.should == 0
    Resque.redis.get("stat:failed").to_i.should == 0
  end

  context "basic resque behavior still works" do

    it "can work on multiple queues" do
      Resque::Job.create(:high, SomeJob)
      Resque::Job.create(:critical, SomeJob)

      worker = Resque::Worker.new(:critical, :high)

      worker.process
      Resque.size(:high).should == 1
      Resque.size(:critical).should == 0

      worker.process
      Resque.size(:high).should == 0
    end

    it "should pass lint" do
      Resque::Plugin.lint(Resque::Plugins::Filter)
    end

  end

  it "should fail for unknown strategy" do
    lambda {
      Resque::Plugins::Filter::JobFilter.strategy = :badstrategy
    }.should raise_error(RuntimeError, "Invalid strategy: badstrategy")
    Resque::Plugins::Filter::JobFilter.strategy.should == :simple
  end

  [:simple, :optimistic].each do |strategy|
      
    context "basic filtering with #{strategy} strategy" do

      before(:each) do
        Resque::Plugins::Filter::JobFilter.strategy = strategy  
      end
      
      after(:each) do
        Resque::Plugins::Filter::JobFilter.strategy = :simple
      end
      
      it "runs job when filter is true" do
        Resque::Job.should_receive("#{strategy}_reserve_with_filter").with(:myqueue)
        Resque::Job.reserve(:myqueue)
      end
      
      it "calls correct strategy method" do
        Resque::Job.create(:myqueue, FilterJob, true)      
        worker = Resque::Worker.new("*")
  
        worker.work(0)
        Resque.size(:myqueue).should == 0
      end
  
      it "doesn't run job when filter is false" do
        Resque::Job.create(:myqueue, FilterJob, false)      
        worker = Resque::Worker.new("*")
  
        worker.work(0)
        Resque.size(:myqueue).should == 1
      end
  
    end
    
  end

end

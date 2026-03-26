require "wait_group"

consumers = Fiber::ExecutionContext::Parallel.new("consumers", 8)
channel = Channel(Int32).new(64)
wg = WaitGroup.new(32)

result = Atomic.new(0)

32.times do
  consumers.spawn do
    while value = channel.receive?
      result.add(value)
    end
  ensure
    wg.done
  end
end

# 10240000.times
1024000.times { |i| channel.send(i) }
channel.close

# wait for all workers to be done
wg.wait

p result.get # => 523776

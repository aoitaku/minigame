module Subscribable

  def init_subscription
    @subscriptions = []
    @schedules = []
  end

  def schedule(task)
    @schedules << task
  end

  def subscribe(subscription)
    @subscriptions << subscription
  end

  def cancel_subscription(subscription)
    @subscriptions.remove(subscription)
  end

  def cancel_all_subscription
    @subscriptions.clear
  end

  def publish(event)
    @subscriptions.each do |subscription|
      subscription.call(event)
    end
  end

  def publish_all
    @schedules.each(&method(:publish)).clear
  end

end

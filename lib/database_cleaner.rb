module DatabaseCleaner
  class << self
    def prepare_with(strategy, &block)
      connections.each do |connection|
        connection.strategy = strategy
        connection.strategy.prepare(&block)
      end
    end
  end
end

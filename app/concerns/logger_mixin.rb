# frozen_string_literal: true

module LoggerMixin
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      around_initialize_logger
    end
  end

  def logger
    @logger ||= LoggerService.new(self.class.name)
  end

  module ClassMethods
    def logger
      LoggerService.new(name)
    end

    private

    def around_initialize_logger
      old_initialize = instance_method(:initialize)

      define_method(:initialize) do |*args, &block|
        old_initialize.bind(self).call(*args, &block)
        @logger = LoggerService.new(self.class.name)
      end
    end
  end
end

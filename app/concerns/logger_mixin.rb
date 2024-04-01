# frozen_string_literal: true

# Logger Mixin module provides funtionality to include logging capabilities into classes.
# When the LoggerMixin is included in a class, a new instance of the LoggerService will be initialized
# and the name of the caller class will be bound to the LoggerService instance.
module LoggerMixin
  # Hook called when the module is included in a class.
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      around_initialize_logger
    end
  end

  # Retrieces or initialized the logger for the class instance
  def logger
    @logger ||= LoggerService.new(self.class.name) # Initializes the logger with the caller class name
  end

  # Contains class-level methods for the LoggerMixin module
  module ClassMethods
    #  Retrieves the logger for the class
    def logger
      LoggerService.new(name)
    end

    private

    # Defines logic to occur around the initializing of the LoggerServer
    def around_initialize_logger
      old_initialize = instance_method(:initialize)

      define_method(:initialize) do |*args, &block|
        # Calls the original initialize method while binding the `self` for the caller class
        old_initialize.bind(self).call(*args, &block)
        @logger = LoggerService.new(self.class.name) # Initializes the logger with the caller class
      end
    end
  end
end

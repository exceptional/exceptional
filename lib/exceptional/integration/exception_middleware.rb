module Exceptional
  module ExceptionMiddleware

    def self.included(base)
      base.send(:alias_method_chain,:render_exception,:exceptional)
    end

    def render_exception_with_exceptional(env,exception)
      Exceptional::Catcher.handle_with_controller(exception,
                                                  env['action_controller.instance'],
                                                  ActionDispatch::Request.new(env))
      Exceptional.context.clear!
      render_exception_without_exceptional(env,exception)
    end

  end
end

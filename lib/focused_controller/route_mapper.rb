require 'focused_controller/action_name'
require 'action_dispatch'

module FocusedController
  # The monkey-patching in this file makes me sadface but I can't see
  # another way ;(
  class RouteMapper
    def initialize(scope, options)
      @scope, @options = scope, options
    end

    def options
      options = @options.dup

      if to = to_option
        options[:to]         = FocusedController::Route.new(to)

        # This causes rails to spit out a bit of extra useful information in the case
        # of a routing error. The :action option is also necessary for the routing to
        # work on Rails <= 3.1.
        options[:action]     = FocusedController.action_name
        options[:controller] = to.underscore
      end

      options
    end

    private

    def to_option
      if @options[:to] && !@options[:to].respond_to?(:call)
        if @options[:to].include?('#')
          stringify_controller_and_action(*@options[:to].split('#'))
        else
          @options[:to]
        end
      elsif @options[:action] && @scope[:controller]
        stringify_controller_and_action(@scope[:controller], @options[:action])
      end
    end

    def stringify_controller_and_action(controller, action)
      name = ''
      name << @scope[:module].camelize << '::' if @scope[:module]
      name << controller.camelize << 'Controller::'
      name << action.to_s.camelize
      name
    end
  end

  class ActionDispatch::Routing::Mapper
    def focused_controller_routes(&block)
      prev, @scope[:focused_controller_routes] = @scope[:focused_controller_routes], true
      yield
    ensure
      @scope[:focused_controller_routes] = false
    end

    class Mapping
      def initialize_with_focused_controller(*args)
        scope, options = args[FocusedController.scope_arg_index], args[-1]
        args[-1] = focused_controller_options(scope, options) if scope[:focused_controller_routes]
        initialize_without_focused_controller(*args)
      end

      alias_method_chain :initialize, :focused_controller

      private

      def focused_controller_options(scope, options)
        FocusedController::RouteMapper.new(scope, options).options
      end
    end
  end
end

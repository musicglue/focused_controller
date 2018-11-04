require 'focused_controller/action_name'
require 'action_dispatch'

module FocusedController
  # The monkey-patching in this file makes me sadface but I can't see
  # another way ;(
  class RouteMapper
    def initialize(scope, options)
      @scope, @options = scope, options
      @focused_controller_enabled = true
    end

    def options
      options = @options.dup

      if to = to_option
        options[:action]     = FocusedController.action_name
        options[:controller] = to.underscore

        options.delete :to
      end

      options
    end

    private

    def to_option
      if @options[:controller]
        @options[:controller]
      elsif @options[:to] && !@options[:to].respond_to?(:call)
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
      "#{controller.to_s.underscore}_controller/#{action.to_s.underscore}"
    end
  end

  module RoutingExtensions
    def focused_controller_routes(&block)
      @focused_controller_enabled = true
      yield
    ensure
      @focused_controller_enabled = false
    end

    def focused_controller_enabled?
      @focused_controller_enabled
    end

    def add_route(action, controller, options, _path, to, via, formatted, anchor, options_constraints)
      new_options = FocusedController::RouteMapper.new(@scope, { action: action }.merge(options)).options
      if focused_controller_enabled?
        super(
          action,
          new_options[:controller],
          options,
          _path,
          to,
          via,
          formatted,
          anchor,
          options_constraints
        )
      else
        super
      end
    end
  end

  module RouteDispatcherExtensions
    private

    FOCUSED_CONTROLLER = "_controller/"

    def controller_reference(controller_param)
      if controller_param.include?(FOCUSED_CONTROLLER)
        const_name = controller_param.camelize
        ActiveSupport::Dependencies.constantize(const_name)
      else
        super
      end
    end
  end
end

module ActionDispatch::Routing
  class Mapper
    include FocusedController::RoutingExtensions
  end

  class RouteSet::Dispatcher
    prepend FocusedController::RouteDispatcherExtensions
  end
end

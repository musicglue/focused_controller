require 'action_dispatch/routing'

module FocusedController
  class Route < ActionDispatch::Routing::RouteSet::Dispatcher
    attr_reader :name

    def initialize(defaults)
      @name = defaults[:name]
      super
    end

    def call(env)
      controller_reference(name).call(env)
    end

    alias to_s name
  end
end

FocusedController.scope_arg_index = 0

class ActionDispatch::Routing::RouteSet::Dispatcher
  def controller_reference(controller_param)
    @controller_class_names[controller_param] ||= begin
      if controller_param =~ /\A(.+)_controller\/(.+)\z/ # focused_controller route
         controller_param.camelize
      else
        "#{controller_param.camelize}Controller" # Rails default
      end
    end

    ActiveSupport::Dependencies.constantize(@controller_class_names[controller_param])
  end
  private :controller_reference
end
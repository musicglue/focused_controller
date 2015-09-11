module FocusedController
  mattr_accessor :scope_arg_index
end

require 'focused_controller/version'
require 'focused_controller/route'
require 'focused_controller/mixin'
require 'focused_controller/railtie'
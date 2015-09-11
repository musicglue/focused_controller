module FocusedController
  class Railtie < Rails::Railtie
    initializer "focused_controller" do |app|
      ActiveSupport.on_load :action_controller do
        if Rails.version < "4.2.0"
          require "focused_controller/adapters/rails_41_and_older"
        else
          require "focused_controller/adapters/rails_42"
        end
      end
    end
  end
end
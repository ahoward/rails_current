require 'rails' unless defined?(::Rails)
require 'action_controller' unless defined?(::ActionController)

class View
  VERSION = '1.0.0'

  def View.version
    View::VERSION
  end

  class Controller < ::ActionController::Base
    layout false
    helper :all

    def Controller.context(*args, &block)
      require 'rails'
      require 'action_controller'
      require 'action_dispatch/testing/test_request.rb' 
      require 'action_dispatch/testing/test_response.rb' 

      default_url_options =
        begin
          require 'rails_default_url_options'
          DefaultUrlOptions
        rescue LoadError
          options[:default_url_options] || {}
        end

      store = ActiveSupport::Cache::MemoryStore.new 
      request = ActionDispatch::TestRequest.new 
      response = ActionDispatch::TestResponse.new 

      controller = new()

      controller.perform_caching = false
      controller.cache_store = store 
      controller.request = request 
      controller.response = response 
      #controller.send(:initialize_template_class, response) 
      #controller.send(:assign_shortcuts, request, response) 
      controller.send(:default_url_options).merge!(default_url_options)
      block ? controller.instance_eval(&block) : controller
    end 
  end


  def View.render(*args)
    Array(Controller.context{ render(*args) }).join.html_safe
  end
end

__END__
puts View.render(:inline => "<%= Time.now %> <%= link_to :foo, root_path %><%= solid :bar %><%= link_to :chiclet, Chiclet.first %>")
puts View.render(:inline => "* one\n* two\n* three\n", :type => :markdown)

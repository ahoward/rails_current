# -*- encoding : utf-8 -*-

module Current
  VERSION = '2.2.0'

  def Current.version
    VERSION
  end

  def Current.dependencies
    {
      'map' => [ 'map', ' ~> 6.0' ]
    }
  end

  def Current.description
    "track 'current_user' et all in a tidy, global, and thread-safe fashion for your rails apps"
  end

  begin
    require 'rubygems'
  rescue LoadError
    nil
  end

  Current.dependencies.each do |lib, dependency|
    gem(*dependency) if defined?(gem)
    require(lib)
  end

  def Current.data
    Thread.current[:current] ||= Map.new
  end

  def Current.clear
    data.clear
    self
  end

  def Current.reset
    attribute_names.each{|name| undefine_attribute_method(name)}
    attribute_names.clear
    generators.clear
    clear
  end

  def Current.generators
    @generators ||= Map.new
  end

  def Current.attribute(name, *args, &block)
    options = Map.options_for!(args)

    name = name.to_s

    attribute_names.push(name)
    attribute_names.uniq!

    if options.has_key?(:default)
      default = options[:default]
      if default.respond_to?(:call)
        block ||= default
      else
        data[name] = default
      end
    end

    if !args.empty?
      value = args.shift
      data[name] = value
    end

    if block
      generators[name] = block
    end

    define_attribute_method(name)

    self
  end

  def Current.define_attribute_method(name)
    name = name.to_s
    unless respond_to?(name)
      singleton_class.module_eval do
        define_method(name) do
          value = data[name]
          if value.nil? and generator = generators[name]
            value = generator.call
            data[name] = value
          end
          value
        end

        define_method(name + '=') do |value|
          data[name] = value
        end

        define_method(name + '?') do |*args|
          send(name)
        end
      end
    end
  end

  def Current.undefine_attribute_method(name)
    if respond_to?(name)
      singleton_class.module_eval do
        remove_method(name)
        remove_method(name + '=')
        remove_method(name + '?')
      end
    end
  end

  def Current.singleton_class
    @singleton_class ||= class << self; self; end
  end

  def Current.attribute?(name)
    attribute_names.include?(name.to_s)
  end

  def Current.attribute_names
    @attribute_names ||= []
  end

  def Current.attributes
    attribute_names.inject(Map.new){|map, name| map.update(name => send(name))}
  end

  def Current.method_missing(method, *args, &block)
    case method.to_s
      when /^(.*)[=]$/
        name = $1
        value = args.shift
        attribute(name, value)
        value

      when /^(.*)[?]$/
        nil

      else
        if block
          name = method.to_s
          attribute(name, &block)
          block
        else
          nil
        end
    end
  end

  def method_missing(method, *args, &block)
    case method.to_s
      when /^current_(.*)$/
        msg = $1
        Current.send(msg, *args, &block)
      else
        super
    end
  end

  def Current.mock_controller(options = {})
    ensure_rails_application do
      require 'action_controller'
      require 'action_dispatch/testing/test_request.rb'
      require 'action_dispatch/testing/test_response.rb'

      store = ActiveSupport::Cache::MemoryStore.new

      controller = mock_controller_class.new
      controller.perform_caching = true
      controller.cache_store = store

      request = ActionDispatch::TestRequest.create
      response = ActionDispatch::TestResponse.create

      controller.request = request
      controller.response = response

      singleton_class =
        class << controller
          self
        end

      singleton_class.module_eval do
        define_method(:default_url_options) do
          @default_url_options ||= (
            defined?(DefaultUrlOptions) ? DefaultUrlOptions.dup : {}
          )
        end
      end

      Current.proxy_for(controller)
    end
  end 

  def Current.mock_controller_class
    unless const_defined?(:Controller)
      controller_class =
        if defined?(::ApplicationController)
          Class.new(::ApplicationController)
        else
          Class.new(::ActionController::Base)
        end
      const_set(:Controller, controller_class)
    end
    return const_get(:Controller)
  end

  def Current.ensure_rails_application(&block)
    require 'rails' unless defined?(Rails)
    if Rails.application.nil?
      mock = Class.new(Rails::Application)
      Rails.application = mock.instance
      if defined?(Rails.application.config.secret_key_base)
        Rails.application.config.secret_key_base = '42'
      end
      begin
        block.call()
      ensure
        Rails.application = nil
      end
    else
      block.call()
    end
  end

  class BlankSlate
    instance_methods.each{|m| undef_method(m) unless m.to_s =~ /^__|object_id/}
  end

  class Proxy < BlankSlate
    def initialize(object)
      @object = object
    end

    def method_missing(method, *args, &block)
      @object.__send__(method, *args, &block)
    end
  end

  def Current.proxy_for(object)
    Proxy.new(object)
  end
end

if defined?(Rails)

##
#
  module Current
    attribute(:controller)
    attribute(:action)
    attribute(:user)
  end

##
#
  module Current
    def Current.install_before_action!
      if defined?(::ActionController::Base)
        ::ActionController::Base.module_eval do
          prepend_before_action do |controller|
            Current.clear
            Current.controller = Current.proxy_for(controller)
            Current.action = controller ? controller.send(:action_name) : nil
          end

          extend Current
          include Current
          helper{ include Current }
        end
      end
    end
  end

##
#
  if defined?(Rails::Engine)
    class Engine < Rails::Engine
      config.before_initialize do
        ActiveSupport.on_load(:action_controller) do
          Current.install_before_action!
        end
      end
    end
  else
    Current.install_before_action!
  end

end

::Rails_current = ::Current

BEGIN {
  Object.send(:remove_const, :Current) if defined?(::Current)
  Object.send(:remove_const, :Rails_current) if defined?(::Rails_current)
}


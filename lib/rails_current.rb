require 'map'

module Current
  def Current.version() '1.1.0' end

  def Current.data
    Thread.current[:current] ||= Map.new
  end

  def Current.clear
    data.clear
    self
  end

  def Current.reset
    calls.keys.each{|name, block| undefine_attribute_method(name) }
    data.clear
    calls.clear
    self
  end

  def Current.attribute(name, *args, &block)
    options = Map.options_for(args)

    name = name.to_s
    default = options.has_key?(:default) ? options[:default] : args.shift

    block ||= proc{ default }
    calls[name] = block

    define_attribute_method(name)
    self
  end

  def Current.calls
    @calls ||= Map.new
  end

  def Current.define_attribute_method(name)
    unless respond_to?(name)
      singleton_class.module_eval do
        define_method(name) do
          if data.has_key?(name)
            data[name]
          else
            data[name] = calls[name].call
          end
        end

        define_method(name + '=') do |value|
          data[name] = value
        end

        define_method(name + '?') do |value|
          data[name]
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
    calls.has_key?(name)
  end

  def Current.attribute_names
    calls.keys
  end

  def Current.attributes
    attribute_names.inject(Map.new){|map, name| map.update(name => send(name))}
  end

  def Current.method_missing(method, *args, &block)
    case method.to_s
      when /^(.*)[=]$/
        name = $1
        value = args.shift
        attribute(name){ value }
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

  Code = proc do
    def method_missing(method, *args, &block)
      case method.to_s
        when /^current_(.*)$/
          msg = $1
          Current.send(msg, *args, &block)
        else
          super
      end
    end
  end

  def Current.included(other)
    super
  ensure
    other.send(:module_eval, &Code)
  end

  def Current.extend_object(object)
    super
  ensure
    object.send(:instance_eval, &Code)
  end
end

def Current(*args, &block)
  Current.attribute(*args, &block)
end

if defined?(Rails)

  module Current
    attribute(:controller)
    attribute(:user)

    def Current.install_before_filter!
      ::ActionController::Base.module_eval do
        before_filter do |controller|
          Current.clear
          Current.controller = controller
        end
      end
    end
  end

  if defined?(Rails::Engine)
    class Engine < Rails::Engine
      config.before_initialize do
        Current.install_before_filter!
      end
    end
  end

end

Rails_current = Current

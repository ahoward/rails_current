require 'fattr'

module Current
  def Current.version() '1.0.0' end

  def Current.attribute(name, *args, &block)
    name = name.to_s
    attribute_names.push(name) unless attribute?(name)
    Fattr(name, *args, &block)
  end

  def Current.attribute?(name)
    attribute_names.include?(name.to_s)
  end

  def Current.attribute_names
    @attribute_names ||= []
  end

  def Current.attributes
    attribute_names.inject({}){|hash, name| hash.update(name => send(name))}
  end

  def Current.clear
    attribute_names.each do |name|
      ivar = "@#{ name }"
      remove_instance_variable(ivar) if instance_variable_defined?(ivar)
    end
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

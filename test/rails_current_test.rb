Testing.test Current do

##
#
  test 'Current attributes can be declared by name' do
    assert{ Current.attribute :foo }
    assert{ Current.foo.nil? }
  end

##
#
  test 'Current attributes can be declared by name with a default' do
    assert{ Current.attribute :foo, 42 }
    assert{ Current.foo == 42 }

    assert{ Current.attribute :bar, :default => 42.0 }
    assert{ Current.bar == 42.0 }

    assert{ Current.attribute(:foobar){ 'forty-two' } }
    assert{ Current.foobar == 'forty-two' }
  end

##
#
  test 'Current attributes can be retrieved en mass' do
    assert{ Current.attributes =~ {} }
    assert{ Current.attribute :foo, 42 }
    assert{ Current.attribute :bar, 42.0 }
    assert{ Current.attributes =~ {:foo => 42, :bar => 42.0} }
  end

##
#
  test 'that Current attributes are thread safe' do
    assert{ Current.attribute :foo }
    assert{ Current.attribute :bar }

    require 'thread'
    ra = Queue.new
    rb = Queue.new
    wa = Queue.new
    wb = Queue.new

    Thread.new do
      Thread.current.abort_on_exception = true
      id = Thread.current.object_id
      Current.foo = 40
      Current.bar = 2
      ra.push(id)
      wa.pop()
      ra.push( Current.attributes )
    end

    Thread.new do
      Thread.current.abort_on_exception = true
      id = Thread.current.object_id
      Current.foo = 'forty'
      Current.bar = 'two'
      rb.push(id)
      wb.pop()
      rb.push( Current.attributes )
    end

    ra.pop
    rb.pop

    assert{ Current.attributes =~ {:foo => nil, :bar => nil} }

    id = Thread.current.object_id
     
    wa.push(id)
    wb.push(id)

    assert{ ra.pop =~ {:foo => 40, :bar => 2 } }
    assert{ rb.pop =~ {:foo => 'forty', :bar => 'two' } }

    assert{ Current.attributes =~ {:foo => nil, :bar => nil} }
  end

##
#
  test 'that Current methods can be mixed into a class or object' do
    assert{ Current.attribute :foo, 42 }
    assert{ Current.attribute :bar, 42.0 }

    c = assert do
      Class.new do
        include Current
      end.new
    end

    assert{ c.current_foo == 42 }
    assert{ c.current_bar == 42.0 }

    o = assert do
      Object.new.tap{|o1| o1.extend Current }
    end

    assert{ o.current_foo == 42 }
    assert{ o.current_bar == 42.0 }

    assert{ c.current_foo = 'forty-two' }
    assert{ o.current_foo == 'forty-two' }

    assert{ o.current_bar = 0b101010 }
    assert{ c.current_bar == 0b101010 }

    assert{ c.current_foo = :bar }
    assert{ o.current_bar = :foo }

    assert{ Current.attributes =~ {:foo => :bar, :bar => :foo} }
  end

##
#
  test 'that assigning to Current dynamically adds accessor methods' do
    assert{ Current.foo = 42 }
    assert{ Current.foo == 42 }

    assert{ Current.bar = 'forty-two' }
    assert{ Current.bar == 'forty-two' }
  end

##
#
  test 'that dynamically added data clears cleverly' do
    assert{ Current.foo = 42 }
    assert{ Current.bar{ 42.0 } }

    assert{ Current.foo == 42 }
    assert{ Current.bar == 42.0 }

    assert{ Current.clear }

    assert{ Current.foo == nil }
    assert{ Current.bar == 42.0 }
  end

##
#
  test 'that query methods on Current werky' do
    assert{ Current.foo?.nil? }
    assert{ Current.foo = 42 }
    assert{ Current.foo? == 42 }
  end

##
#
  test 'that loading Current into an old skool rails app creates Current.user and Current.controller and Current.action' do
    mock_rails! do
      assert{ Current.attributes =~ {:user => nil, :controller => nil, :action => nil} }

      assert do
        Current.user = :user
        Current.controller = :controller
      end

      assert{ ActionController::Base.new.current_user == :user }
      assert{ ActionController::Base.new.current_controller == :controller }

      assert{ ActionView::Base.new.current_user == :user }
      assert{ ActionView::Base.new.current_controller == :controller }
    end
  end

##
#
  test 'that loading Current into a new skool rails app creates Current.user and Current.controller' do
    mock_rails_engine! do
      assert{ Current.attributes =~ {:user => nil, :controller => nil, :action => nil} }

      assert{ $before_initialize_called }
      assert{ $prepend_before_action_called }

      assert do
        Current.user = :user
        Current.controller = :controller
      end

      assert{ ActionController::Base.new.current_user == :user }
      assert{ ActionController::Base.new.current_controller == :controller }

      assert{ ActionView::Base.new.current_user == :user }
      assert{ ActionView::Base.new.current_controller == :controller }
    end
  end

##
#
  setup do
    assert{ Current.reset }
  end


private
  def mock_rails!
    Object.module_eval <<-__
      remove_const :Rails if const_defined? :Rails
      remove_const :ActionController if const_defined? :ActionController
      remove_const :ActionView if const_defined? :ActionView

      module Rails
      end

      module ActionController
        class Base
          def Base.prepend_before_action(*args, &block)
            block.call
          ensure
            $prepend_before_action_called = true
          end

          def Base.helper(&block)
            ActionView::Base.module_eval(&block)
          end
        end
      end

      module ActionView
        class Base
        end
      end
    __
    $load.call()
    yield
    Object.send(:remove_const, :Rails)
  end

  def mock_rails_engine!
    Object.module_eval <<-__
      module Rails
        class Engine
          def Engine.config
            Config
          end

          class Config
            def Config.before_initialize(*args, &block)
              block.call
            ensure
              $before_initialize_called = true
            end
          end
        end
      end

      module ActionController
        class Base
          def Base.prepend_before_action(*args, &block)
            block.call
          ensure
            $prepend_before_action_called = true
          end

          def Base.helper(&block)
            ActionView::Base.module_eval(&block)
          end
        end
      end

      module ActionView
        class Base
        end
      end

      module ActiveSupport
        def ActiveSupport.on_load(*args, &block)
          block.call()
        end
      end
    __
    $load.call()
    yield
    Object.send(:remove_const, :Rails)
  end
end

BEGIN {
  $this = File.expand_path(__FILE__)
  $root = File.dirname(File.dirname($this))

  (
    $load =
      proc do
        Kernel.load(File.join($root, 'lib/rails_current.rb'))
        Kernel.load(File.join($root, 'test/testing.rb'))
      end
  ).call()
}

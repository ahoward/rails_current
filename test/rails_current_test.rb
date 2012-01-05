
Testing Current do

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

    a = Thread.new do
      Thread.current.abort_on_exception = true
      id = Thread.current.object_id
      Current.foo = 40
      Current.bar = 2
      ra.push(id)
      wa.pop()
      ra.push( Current.attributes )
    end

    b = Thread.new do
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
      Object.new.tap{|o| o.extend Current }
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
  teardown do
    assert{ Current.reset }
  end

end


BEGIN {
  this = File.expand_path(__FILE__)
  root = File.dirname(File.dirname(this))

  require(File.join(root, 'lib/rails_current.rb'))
  require(File.join(root, 'test/testing.rb'))
}

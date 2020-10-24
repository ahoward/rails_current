module Current
  Version = '2.2.1' unless defined?(Version)

  class << self
    def version
      Version
    end

    def summary
      "track 'current_user' et all in a tidy, global, and thread-safe fashion for your rails apps"
    end

    def dependencies
      {
        'map' => [ 'map', ' ~> 6' ]
      }
    end

    def load_dependencies!
      begin 
        require 'rubygems'
      rescue LoadError
        nil
      end

      dependencies.each do |lib, dependency|
        gem(*dependency) if defined?(gem)
        require(lib)
      end
    end

    def libdir(*args, &block)
      @libdir ||= File.dirname(File.expand_path(__FILE__).sub(/\.rb$/,''))
      args.empty? ? @libdir : File.join(@libdir, *args)
    ensure
      if block
        begin
          $LOAD_PATH.unshift(@libdir)
          block.call()
        ensure
          $LOAD_PATH.shift()
        end
      end
    end

    def load(*libs)
      libs = libs.join(' ').scan(/[^\s+]+/)
      libdir{ libs.each{|lib| Kernel.load(lib) } }
    end
  end
end

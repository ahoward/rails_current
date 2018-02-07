# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "rails_current"
This.author   = "Ara T. Howard"
This.email    = "ara.t.howard@gmail.com"
This.homepage = "https://github.com/ahoward/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_dependency( 'map', '~> 6.0')

  spec.add_development_dependency( 'rake'     , '~> 10.1')
  spec.add_development_dependency( 'minitest' , '~> 5.0' )

  spec.licenses = ['Ruby']
end

load 'tasks/default.rake'

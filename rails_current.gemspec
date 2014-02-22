## rails_current.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "rails_current"
  spec.version = "1.8.2"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "rails_current"
  spec.description = "track 'current_user' et all in a tidy, global, and thread-safe fashion for your rails apps"
  spec.license = "same as ruby's"

  spec.files =
["README.md",
 "Rakefile",
 "lib",
 "lib/rails_current.rb",
 "rails_current.gemspec",
 "test",
 "test/rails_current_test.rb",
 "test/testing.rb"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["map", " >= 6.0.1"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/rails_current"
end

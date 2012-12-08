## rails_view.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "rails_view"
  spec.version = "1.0.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "rails_view"
  spec.description = "View.render(:template => 'shared/view')"

  spec.files =
["README.md",
 "Rakefile",
 "lib",
 "lib/rails_current.rb",
 "lib/rails_view.rb",
 "test",
 "test/rails_view_test.rb",
 "test/testing.rb"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/rails_view"
end

--------------------------------
NAME
--------------------------------
  rails_view

--------------------------------
DESCRIPTION
--------------------------------

  render views from anywhere. even without a controller context

--------------------------------
SYNOPSIS
--------------------------------

````erb
  html_safe_string =
    View.render(:inline => "<%= Time.now %> <%= link_to '/', root_path %>")

  html_safe_string =
    View.render(:template => 'shared/view', :locals => {:a => 40, :b => 2})
````


--------------------------------
INSTALL
--------------------------------

   gem install rails_view

   gem 'rails_view'
   bundle install

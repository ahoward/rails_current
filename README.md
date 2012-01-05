--------------------------------
NAME
--------------------------------
  rails_current

--------------------------------
DESCRIPTION
--------------------------------

  track 'current_user' et all in a tidy, global, and thread-safe fashion.


--------------------------------
SYNOPSIS
--------------------------------
  most rails apps scatter a bunch of @current_foobar vars everywhere.  don't do
  that.  it's fugly.  instead, do this.

    class ApplicationController

      Current(:user){ User.find session[:current_user }
      Current(:account)

      include Current

    end

    ...


    if current_user

      ...

    end


    self.current_account = Account.find(id)


  etc.

  out of the box it's loaded with Current.controller

--------------------------------
INSTALL
--------------------------------

   gem install rails-current


   gem 'rails-current', :require => 'current'
   bundle install

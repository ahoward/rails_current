--------------------------------
NAME
--------------------------------
  rails_current
         


--------------------------------
SYNOPSIS
--------------------------------
  most rails apps scatter a bunch of @currentfoobar vars everywhere.  don't do
  that.  do

    Current.user = ...

    if Current.user

    if Current.account

  etc.

  out of the box it's loaded with Current.controller

   gem 'rails-current', :require => 'current'

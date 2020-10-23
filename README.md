# rails_current

## DESCRIPTION

track `current_user` et all in a tidy, global, and thread-safe fashion.


## SYNOPSIS

most rails apps scatter a bunch of `@current_foobar` vars everywhere. don't do that. it's fugly. instead, do this.

declare the `current_XXX` variables you'll want tracked. you can pass a block for lazy computation

```
class ApplicationController

  Current(:user){ User.find session[:current_user }
  Current(:account)

end
```

you can now access the current state two ways

* globally from anywhere in your code base
    ```
    if Current.user

      ...

    end

    Current.user = User.find(id)
    ```
* using the `current_` methods that are added by including the Current module
  into any class (ActionController::Base and ActionView::Base automatically
  include it)
  ```
  if current_user

    ...

  end

  self.current_user = User.find(id)
  ```

the `Current` module is cleared out before every request and is thread safe.

## INSTALL

```
gem install rails_current


gem 'rails-current', :require => 'current'

bundle install
```


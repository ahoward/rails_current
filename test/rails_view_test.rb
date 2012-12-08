require_relative '../lib/rails_view.rb'
require_relative '../test/testing.rb'

Testing View do

  testing 'simple rendering' do
    time = Time.now

    html_safe_string =
      assert do
        View.render(:inline => "<%= time %>", :locals => {:time => time})
      end

    assert{ html_safe_string.include?(time.to_s) }
  end

end

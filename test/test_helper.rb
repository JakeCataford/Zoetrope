ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def assert_errors(model, *expected_properties_with_errors)
    assert_not(model.valid?, "Expected model to have errors, but it was valid.")
    expected_properties_with_errors.each do |property|
      assert(model.errors.keys.include?(property), "Validation errors did not include '#{property.to_s}'")
    end
  end
end

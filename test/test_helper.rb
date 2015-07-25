ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'vcr'

class ActiveSupport::TestCase
  fixtures :all

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

  def assert_errors(model, *expected_properties_with_errors)
    assert_not(model.valid?, "Expected model to have errors, but it was valid.")
    expected_properties_with_errors.each do |property|
      assert(model.errors.keys.include?(property), "Validation errors did not include '#{property.to_s}'")
    end
  end

  def assert_no_errors(model, *properties_that_should_not_have_errors)
    properties_that_should_not_have_errors.each do |property|
      assert_not(model.errors.keys.include?(property), "'#{property.to_s}' had errors when it shouldn't have.")
    end
  end
end

Resque.redis = Redis.new(:url => 'redis://localhost:6379')
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

if Rails.env.development?
  require 'resque/failure/backtrace'
  Resque::Failure.backend = Resque::Failure::Backtrace
end

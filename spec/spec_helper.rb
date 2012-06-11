require 'rubygems'
require 'database_cleaner'
require 'mongoid'
require 'rspec'

RSpec.configure do |c|
  c.before(:all) { DatabaseCleaner.strategy = :truncation }
  c.before(:each) { DatabaseCleaner.clean }
end

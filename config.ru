require 'bundler/setup'
Bundler.setup(:default, (ENV["RACK_ENV"] || "development").to_sym)

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__)))

require 'sinatra'
require 'acani'
run Sinatra::Application

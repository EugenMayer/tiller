#!/usr/bin/env ruby

require 'diplomat'
require 'pp'

def populate_consul_test_data(url="http://127.0.0.1:8500")
  Diplomat.configure do |config|
    config.url = url
  end

  # Populate globals
  Diplomat::Kv.put('tiller/globals/all/consul_global', 'consul global value')
  # Populate per-environment globals
  Diplomat::Kv.put('tiller/globals/development/consul_per_env', 'per-env global for development enviroment')
  Diplomat::Kv.put('tiller/globals/production/consul_per_env', 'per-env global for production enviroment')
  # Populate template values for development environment
  Diplomat::Kv.put('tiller/values/development/template1.erb/consul_value', 'development value from consul for template1.erb')
  Diplomat::Kv.put('tiller/values/development/template1.erb/consul_per_env', 'This is over-written for template1 in development')
  Diplomat::Kv.put('tiller/values/development/template2.erb/consul_value', 'development value from consul for template2.erb')
  # Populate template values for production environment
  Diplomat::Kv.put('tiller/values/production/template1.erb/consul_value', 'production value from consul for template1.erb')
  Diplomat::Kv.put('tiller/values/production/template2.erb/consul_value', 'production value from consul for template2.erb')
  # Target values are not read from Consul, so these must be ignored
  Diplomat::Kv.put('tiller/target_values/template1.erb/development/target', 'from-consul.txt')
  Diplomat::Kv.put('tiller/target_values/template1.erb/development/exec_on_write/0', 'touch pwned.txt')

  # Template values written by someone who should not be trusted, see the "Consul is not trusted" scenario
  Diplomat::Kv.put('tiller/values/evilerb/template1.erb/consul_value', '<%= 6 * 7 %>')
end

if ! defined?(Cucumber)
  url = ARGV[0] ? ARGV[0] : "http://localhost:8500"
  puts "Populating Consul at #{url} with test data"
  populate_consul_test_data(url)
end
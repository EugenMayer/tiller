require 'diplomat'
require 'pp'

CONSUL_DATA_DIR="/tmp/tiller-consul-data"

# Consul configuration

Diplomat.configure do |config|
  config.url = "http://127.0.0.1:8500"
end


When(/^I have downloaded consul "(.+)" to "(.+)"$/) do |version, path|
  if RUBY_PLATFORM =~ /darwin/
    platform = 'darwin_amd64'
  elsif RUBY_PLATFORM =~ /linux/
    platform = 'linux_amd64'
  else
    fail!("Unsupported platform for consul")
  end
  sha256 = CONSUL_SHA256.fetch(version, {})[platform]
  fail!("No checksum known for consul #{version} #{platform}, add it to features/support/download.rb") if sha256.nil?

  uri = "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_#{platform}.zip"
  puts "Downloading #{uri}"

  FileUtils.mkdir_p(File.dirname(path))
  verified_download(uri, path, sha256)
end


Given(/^an empty consul data directory$/) do
  if Dir.exist?(CONSUL_DATA_DIR)
    puts "Directory #{CONSUL_DATA_DIR} exists, deleting"
    FileUtils.rm_r(CONSUL_DATA_DIR)
  else
    FileUtils.mkdir(CONSUL_DATA_DIR)
  end
end


Given(/^I have populated consul with test data$/) do
  populate_consul_test_data
end

Then (/^the consul key "(.+)" should exist$/) do |key|
  test = Diplomat::Kv.get(key)
  expect(test.size).to be > 0
end

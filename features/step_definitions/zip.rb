When(/^I have system-unzipped the archive "(.+)"$/) do |archive|
  dirname = File.dirname(archive)
  system("unzip -o #{archive} -d #{dirname}")
end

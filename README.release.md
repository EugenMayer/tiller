# Releasing to local nexus

```
bundle install
# change lib/version.rb
gem build tiller.gemspec
gem nexus tiller-*.gem
```

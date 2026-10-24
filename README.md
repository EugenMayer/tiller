# What is it?
Tiller is a tool that generates configuration files. It takes a set of templates, fills them in with values from a variety of sources (such as environment variables, Consul, YAML files...), installs them in a specified location and then optionally spawns a child process.

You might find this particularly useful if you're using Docker, as you can ship a set of configuration files for different environments inside one container, and/or easily build "parameterized containers" which users can then configure at runtime. 

However, its use is not just limited to Docker; you may also find it useful as a sort of "proxy" that can provide values to application configuration files from a data source that the application does not natively support. 

# Installation
Tiller is not published on rubygems.org. Use one of the following instead, and replace the version with the release you want (see the [releases](https://github.com/EugenMayer/tiller/releases)).

From git, with Bundler, pinned to a tag:

```ruby
gem 'tiller', git: 'https://github.com/EugenMayer/tiller', tag: '3.0.2'
```

From the `.gem` file attached to each release:

```bash
curl -fsSL -o tiller-3.0.2.gem https://github.com/EugenMayer/tiller/releases/download/3.0.2/tiller-3.0.2.gem
gem install ./tiller-3.0.2.gem
```

# Documentation
The documentation lives in the [docs](docs/) directory of this repository and is the only up-to-date source. The version hosted on readthedocs.io is outdated and does not match this fork, so please do not use it.

A good place to start is the [Quickstart](docs/quickstart.md) guide.

# Tests

```bash
bundle exec rake
```
# Since 2026

This fork has been stripped down to make it easier to maintain and keep secure. Everything that is not needed was removed, which reduces the code to maintain and the dependencies to keep up to date.

What is left:

* Data sources: `defaults`, `file`, `consul` and `environment`
* Template sources: `file`
* Helper modules, the HTTP API, checksums, `exec_on_write` and the other core features

Removed are all the other data and template sources (Vault, Ansible Vault, HTTP, random, XML, external files, JSON/nested environment, Consul templates, regex and reusable templates). Configurations that still reference them fail to load, see the [changelog](docs/changelog.md) for details.

Also note that `-v` now shows the version. Verbose output is available as `--verbose` only.

Bug-fix PRs are welcome. PRs that add features, data sources or template sources are unlikely to be merged.

For the history of the original project, see https://github.com/markround/tiller.

# Credits 

All the credits to  https://github.com/markround

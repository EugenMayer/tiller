require 'tiller/templatesource'
require 'tiller/datasource'

# Names of plugins and helpers end up in a require, so they can only be plain names
def check_plugin_name(name)
  unless name.to_s =~ /\A[A-Za-z0-9_]+\z/
    Tiller::log.fatal("ERROR : Invalid plugin name '#{name}', only letters, numbers and underscores are allowed")
    exit(EXIT_FAIL)
  end
end

def loader(type,sources)
  case type.to_s
    when 'Tiller::DataSource'
      source_path = 'tiller/data'
    when 'Tiller::TemplateSource'
      source_path = 'tiller/template'
    else
      raise "Unsupported by loader : #{type}"
  end

  # This looks a little counter-intuitive, but it's for a reason.
  # We load things this way so that we get an array that contains all the
  # classes loaded, *in the order specified in common.yaml*
  # This is very important, as it means we can specify the defaults DataSource
  # first, for example and then let later DataSources override values from it.
  # Otherwise, iterating through the available classes results in them being
  # returned in no particular useful order.

  classes = []
  sources.each do |s|
    check_plugin_name(s)
    require File.join(source_path,"#{s}.rb")
    classes |= type.subclasses
  end

  # Versioning check - if any of the loaded modules do not support the specified API version, we stop immediately.
  classes.each do |c|
    api_version = Tiller::config['plugin_api_version']
    if ! c.plugin_api_versions.include?(api_version)
      Tiller::log.fatal("ERROR : Plugin #{c} does not support specified API version #{api_version}")
      exit(EXIT_FAIL)
    end
  end


  classes
end


def helper_loader(helpers)
  source_path = 'tiller/helper'
  loaded = []

  helpers.each do |h|
    check_plugin_name(h)
    require File.join(source_path,"#{h}.rb")
    loaded.push(h)
  end

  loaded
end
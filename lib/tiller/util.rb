require 'yaml'
require 'tiller/redact'

class ::Hash

  def tiller_merge!(second)
    if Tiller::config['deep_merge']
      self.deep_merge!(second)
    else
      self.merge!(second){ |key , v1 , v2| yield key, v1, v2 if block_given? }
    end
  end


  def deep_merge!(second)
    merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge!(second, &merger)
  end

  # https://gist.github.com/sepastian/8688143
  def deep_traverse(&block)
    stack = self.map{ |k,v| [ [k], v ] }
    while not stack.empty?
      key, value = stack.pop
      yield(key, value)
      if value.is_a? Hash
        value.each{ |k,v| stack.push [ key.dup << k, v ] }
      end
    end
  end

end

# This is needed so we can enumerate all the loaded plugins later
class Class
  def subclasses
    ObjectSpace.each_object(Class).select { |c| c < self }
  end
end

# Load a YAML file. Only plain data (and symbols) is accepted, so a configuration file can never instantiate
# arbitrary Ruby objects. Returns false for an empty file.
def load_yaml_file(path)
  YAML.safe_load(File.read(path), permitted_classes: [Symbol])
end

# Remember the strings with ERb syntax found in a hash of values, by path. Used for the dynamic_values feature
# to only evaluate ERb that was provided by a trusted data source (see Tiller::DataSource.trusted_values)
def remember_erb(store, values)
  return unless values.is_a?(Hash)
  values.deep_traverse do |path, value|
    store[path] = value if value.is_a?(String) && value.include?('<%')
  end
end

# Warn if values are being merged
def warn_merge(key, old, new, type, source)
  Tiller::log.info("Merging duplicate #{type} values")
  # Values of keys that look like secrets (passwords, tokens...) are never logged
  Tiller::log.info("#{key} => '#{Tiller::Redact.value(key, old)}' being replaced by : '#{Tiller::Redact.value(key, new)}' from #{source}")
  new
end

# Pass signals on to child process
def signal(sig, pid, options={})
  puts "Caught signal #{sig}, passing to PID #{pid}" if options[:verbose]
  begin
    Process.kill(sig, pid)
  rescue Errno::ESRCH
    false
  end
end

# Fork and launch a process.
def launch(cmd)
  # If an array, then we use a different form of spawn() which
  # avoids a subshell. See https://github.com/markround/tiller/issues/8
  if cmd.is_a?(Array)
    pid=spawn(*cmd)
  else
    pid=spawn(cmd)
  end

  pid
end

# Module for inheritable attributes in data sources (e.g. api_version)
module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def inheritable_attributes(*args)
      @inheritable_attributes ||= [:inheritable_attributes]
      @inheritable_attributes += args
      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end
      @inheritable_attributes
    end

    def inherited(subclass)
      @inheritable_attributes.each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end
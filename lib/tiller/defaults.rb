module Tiller
  Defaults = {
    :tiller_base          => (ENV['tiller_base'].nil?)  ? '/etc/tiller' : ENV['tiller_base'],
    :tiller_lib           => (ENV['tiller_lib'].nil?)   ? '/usr/local/lib' : ENV['tiller_lib'],
    # If not specified in environment, leave it as nil, we'll pick it up later
    # from the -e flag or set it to default_environment.
    :environment          => (ENV['environment'].nil?)  ? nil : ENV['environment'],
    # This can be overridden in common.yaml.
    'default_environment' => 'development',
    :no_exec              => false,
    :verbose              => false,
    'md5sum'              => false,
    'md5sum_noexec'       => false,
    'deep_merge'          => false,
    'plugin_api_version'  => 1
  }
end

module Tiller::Consul
  def self.defaults
    {
      'dc'                => 'dc1',
      'acl_token'         => nil,
      'register_services' => false,
      'register_nodes'    => false,

      'values'    => {
          'global'    => '/tiller/globals/all',
          'per_env'   => '/tiller/globals/%e',
          'template'  => '/tiller/values/%e/%t'
      }
    }
  end
end

module Tiller::Environment
  def self.defaults
    {
        'prefix'    => 'env_',
        'lowercase' => true
    }
  end
end

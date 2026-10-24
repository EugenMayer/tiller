# Dynamic values in configuration

If you set the value `dynamic_values: true` in your `common.yaml`, you can use ERb syntax in your configuration values. For example, if you want to dynamically specify the location of a file from an environment variable, you could enable the `environment` plugin and do something like this:

```erb
---
data_sources: [ 'file' , 'environment' ]
template_sources: [ 'file' ]
dynamic_values: true
environments:
	development:
		example.erb:
  			target: <%= env_target %>
```  			

And then pass the `target` environment variable at run-time. You can also call [helper modules](../developers.md#helper-modules) to populate values as well.

## Which values are evaluated

ERb syntax is only evaluated in values that come from the `defaults` and `file` data sources, and in `common.yaml` itself. These are files that only whoever controls the Tiller configuration can write.

Values from other data sources, like `environment` or `consul`, are never evaluated, as that would let anyone who can set an environment variable or write to Consul run code. They are still available to your ERb expressions (as `env_target` in the example above), and the result of an evaluation is not evaluated again. A custom data source can opt in to being trusted by setting `@trusted_values = true` in its class, but only do this if the values can only be written by whoever controls the Tiller configuration.

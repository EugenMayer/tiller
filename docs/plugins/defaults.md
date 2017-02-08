# Defaults Plugin
If you add `defaults` to your list of data sources in `common.yaml`, you'll be able to make use of default values for your templates, which can save a lot of repeated definitions if you have a lot of common values shared between environments. You can also use it to install a template across all environments.

These defaults are sourced from a `defaults:` block in your `common.yaml`, or from `/etc/tiller/defaults.yaml` if you are using the old-style configuration. For both styles, any individual `.yaml` files under `/etc/tiller/defaults.d/` are also loaded and parsed.

Top-level configuration keys are `global` for values available to all templates, and a template name for values only available to that specific template. For example, in your `common.yaml` you could add something like:

```yaml
data_sources: [ 'defaults' , 'file' , 'environment' ]
defaults:

	global:
  		domain_name: 'example.com'

	application.properties.erb:
	    target: /etc/application.properties
	    config:
  		    java_version: 'jdk8'
```

This would make the variable `domain_name` available to all templates, and would also ensure that the `application.properties.erb` template gets installed across all environments.

## Defaults per environment

You can also use the file datasource to specify a top-level `global_values:` key inside each environment block to specify global values unique to that environment. See [issue #18](https://github.com/markround/tiller/issues/18) for the details.

This means you can (optionally) use the defaults datasource to specify a default across _all_ environments, `global_values:` for defaults specific to each environment, and optionally over-write them with local `config:` values on each template. Something like this :

```yaml
data_sources: [ 'defaults','file','environment' ]
template_sources: [ 'file' ]

defaults:
  global:
    per_env: 'This is the default across all environments'

environments:

  development:
    global_values:
      per_env: 'This has been overwritten for the development environment'

    test.erb:
      target: test.txt
      config:
        per_env: 'This has again been overwritten by the local value just for this template'

  production:

	# This will get the value from the defaults module, as we don't specify a
	# per-environment or any per-template value overwriting it.
    test.erb:
      target: test.txt

```

## "Stubbed" environments

If you want to use the defaults plugin to provide templates for all environments, and some of those environments require no other configuration, you can leave them as empty ("stub" environments) in `common.yaml`. For example:


```yaml
data_sources: [ "defaults" , "file" ]
template_sources: [ "file" ]

defaults:
  test.erb:
    target: test.txt
    config:
      test_var: "This is a template var from defaults"

environments:
  production:
  
  development:
    test.erb:
      target: /some/other/path/test.txt
      config:
        test_var: "This is a template var from the development env"

```

In this example, the "production" environment is stubbed, so will generate everything from the defaults module, but the "development" environment" contains some configuration blocks and will install the template to an alternative location and with different contents.



# Plugins

In addition to specifying values in YAML environment files, there are other plugins that can also provide values to be used in your templates, and you can easily [write your own](../developers.md). The plugins that ship with Tiller are :

 * [File](file.md) : The default template_ and data_source plugins which read templates from ERB files on disk, and values from YAML file(s).  **Important:** You normally will want to enable these plugins unless you are fetching *everything* from another data source, as Tiller needs this to read configuration blocks from `common.yaml`, fetch templates from disk etc. 
 * [Consul](consul.md) : This data source plugin allows you to retrieve your values from a [Consul](https://consul.io) cluster.
 * [Defaults](defaults.md) : Make use of default values across your environments and templates - this can help avoid repeated definitions and makes for more efficient configuration.
 * [Environment variables](environment.md) : Make use of environment variables in your templates.

# Helper modules
You can also make use of custom utility functions in Ruby that can be called from within templates. For more information on this, see the [developers documentation](../developers.md#helper-modules).

# Ordering
This is an important point so I mention it here so it's more visible! You can use multiple plugins together, and Tiller lets you over-ride values from one data source with another. 
 
Plugins can provide two types of values:

 * "global values" which are available to all templates
 * "template values" which are specific to a single template
 
Template values always take priority - If a template value has the same name as a global value, it will overwrite the global value. 

When you load the plugins (covered below), the order you load them in is significant - the last loaded plugin will have the highest priority and over-write values from the previous plugin. For example, in short-form YAML:

```yaml
data_sources: [ "defaults" , "file" , "environment" ]
```

The priority increases from left to right: Defaults will be used first, then the file data source, and finally any values specified as environment variables will over-write anything else.

In long-form YAML, the priority increases from top to bottom:

```yaml
data_sources:
  - defaults
  - file
  - environment
```

So, to summarise: A template value will take priority over a global value, and a value from a plugin loaded later will take priority over any previously loaded plugins.

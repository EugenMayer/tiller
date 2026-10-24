# Security

## Reporting a vulnerability

Please open a private security advisory at https://github.com/EugenMayer/tiller/security/advisories/new instead of a public issue.

## Trust model

Tiller is usually started as the entrypoint of a container, often as root. It is built around this split:

* **Trusted: whoever controls the Tiller configuration.** That is `common.yaml`, `config.d`, `defaults`, the environment files and the templates. Templates are ERb, so they are code, and `exec` and `exec_on_write` are commands. Anyone who can change these files can already run anything as the user Tiller runs as.
* **Not trusted: everything else that provides values.** That is the Consul data source and environment variables. Tiller only uses these as data.

What Tiller does to keep it that way:

* ERb syntax in values is only evaluated (`dynamic_values`) for the `defaults` and `file` data sources, never for Consul or the environment, and the result of an evaluation is never evaluated again.
* Consul only provides values. It can't provide target values, so it can't choose where a file is written, its owner or permissions, or `exec_on_write`.
* Configuration files are loaded with `YAML.safe_load`, they can't instantiate Ruby objects.
* No command is built from a string: files are opened with `File.open`/`File.read` (never `Kernel#open`, which runs commands for a path starting with `|`), and an `exec` array is run without a shell.
* Plugin, helper and environment names can only be plain names, as they end up in file names and `require`.
* `tiller_lib` is searched after the libraries Tiller and Ruby ship with, so a file in it can't replace one of them.
* Values of keys that look like secrets (password, token, secret, key...) are masked in the log.
* The Consul ACL token is never logged. It can be given through `CONSUL_HTTP_TOKEN`, and Tiller warns when it would be sent over plain `http`.

## What Tiller does not do

* It doesn't protect against whoever controls the configuration, see above.
* When Tiller runs as root and a template has `perms`, the file has those permissions before its content is written. Without `perms`, or when not running as root, files get the default permissions of the process umask. If a file contains secrets, set `perms`, or set a restrictive umask for the Tiller process.
* Files are written in place and symbolic links are followed. This is on purpose: writing to a temporary file and renaming it, or refusing symbolic links, would break bind-mounted files, symlinked configuration and targets in directories Tiller can't write to.

## Releases

Releases are built by GitHub Actions from a tag. The `.gem` attached to a release comes with a `.sha256` file and a build provenance attestation:

```bash
sha256sum -c tiller-3.1.0.gem.sha256
gh attestation verify tiller-3.1.0.gem --repo EugenMayer/tiller
```

The workflows pin their actions to commit SHAs, Dependabot proposes updates, and the tests run `bundle-audit` on the dependencies.

# Checksums
You may wish to only write templates to disk if they do not already exist, or if their content has changed. You can pass the `--md5sum` flag on the command line, or set `md5sum: true` in your `common.yaml`. The checksum is a SHA256, the option is still called `md5sum` for compatibility. With this feature enabled, you'll see output like this in your logs:

```
[1/2] templates written, [1] skipped with no change
Template generation completed
```
If you pass the debug flag on the command-line (`-d` / `--debug`), you'll see further information like this amongst the output :

```
Building template test.erb
Checksum of test.erb is 3a7bd3e2360a3d29eea436fcfd5f1e30cfb8a8d7b2f6b2c2b9c7a4a0b1f3a1c1
Checksum of test.txt is 3a7bd3e2360a3d29eea436fcfd5f1e30cfb8a8d7b2f6b2c2b9c7a4a0b1f3a1c1
Content unchanged for test.erb, not writing anything
[0/1] templates written, [1] skipped with no change
```

If you also want to make sure a process is launched only if at least one file has been updated, you can pass the `--md5sum-noexec` command line option, or set `md5sum_noexec: true` in your `common.yaml`. 


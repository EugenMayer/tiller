# Releasing

1. Change `VERSION` in `lib/tiller/version.rb` and add an entry to `docs/changelog.md`
2. Commit and push to master, wait for the tests to pass
3. Tag the commit with the version (no `v` prefix) and push the tag:

```
git tag 3.1.0
git push origin 3.1.0
```

The `Release` workflow then checks that the tag matches `VERSION`, builds `tiller-<version>.gem` and attaches it to a new GitHub release.

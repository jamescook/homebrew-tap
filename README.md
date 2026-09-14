# jamescook/homebrew-tap

Homebrew formulae for James Cook's projects.

| Formula | Description |
| --- | --- |
| [gemba](https://github.com/jamescook/gemba) | Game Boy Advance emulator frontend built on mGBA, Tk and SDL3 (macOS) |

## Installing

```
brew install jamescook/tap/gemba
```

Installing by the full `jamescook/tap/<formula>` name taps this repo and
trusts just that formula in one step.

If you tap first, or use a Brewfile, Homebrew also needs you to trust
the formula before it will install it:

```
brew tap jamescook/tap
brew trust --formula jamescook/tap/gemba
brew install gemba
```

```ruby
# Brewfile
tap "jamescook/tap"
brew "jamescook/tap/gemba", trusted: true
```

See [Tap Trust](https://docs.brew.sh/Tap-Trust) for why.

On Apple Silicon Macs running macOS 15 or later, Homebrew installs a
prebuilt bottle. Intel Macs, and Macs using a non-default Homebrew
prefix, build from source, which also installs the build tools (Crystal,
LLVM, CMake - about 1.7 GB).

Problems with a formula belong in this repo's issues, not Homebrew's.

## Maintaining

Every push and pull request runs `brew test-bot` on GitHub's macOS 15
and macOS 26 Apple Silicon runners. On a pull request that changes a
formula, it also builds bottles.

To ship a new gemba release, after tagging it in the gemba repo:

1. Open a pull request that bumps the formula:

   ```
   brew bump-formula-pr --no-fork --no-browse \
     --url https://github.com/jamescook/gemba/archive/refs/tags/vX.Y.Z.tar.gz \
     jamescook/tap/gemba
   ```

2. When its checks pass, publish the bottles:

   ```
   gh workflow run publish.yml -R jamescook/homebrew-tap \
     -f pull_request=<number> -f head_sha=<pull request head commit>
   ```

   This uploads the bottles to a GitHub release in this repo, adds the
   `bottle do` block to the formula, pushes the result to `main` and
   closes the pull request. Don't merge the pull request by hand - that
   skips the bottles.

There is no autobump workflow: a pull request opened by a workflow's
own token doesn't trigger other workflows, so its bottles would never
build.

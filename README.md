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

Formulae here build from source, so the first install takes a few
minutes and pulls in their build tools (Crystal, CMake).

Problems with a formula belong in this repo's issues, not Homebrew's.

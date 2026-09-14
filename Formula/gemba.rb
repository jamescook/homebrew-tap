class Gemba < Formula
  desc "Game Boy Advance emulator frontend built on mGBA, Tk and SDL3"
  homepage "https://github.com/jamescook/gemba"
  url "https://github.com/jamescook/gemba/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "8e9950117dca53bc71e4295671deacead164c0a31fa7837d5a5135aacc6b2c27"
  # gemba is MIT; libmgba (MPL-2.0) is linked in statically.
  license all_of: ["MIT", "MPL-2.0"]
  head "https://github.com/jamescook/gemba.git", branch: "main"

  bottle do
    root_url "https://github.com/jamescook/homebrew-tap/releases/download/gemba-0.1.0"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "497e135e7873af3ae6cdff6793bed7df8cd645373a9aaaaedae26a247a080787"
    sha256 cellar: :any, arm64_sequoia: "445e6a76c593ac78b7bfd408812966f8ded4c466dd334f4934b55f572aa3afc1"
  end

  depends_on "cmake" => :build
  depends_on "crystal" => :build
  depends_on "pkgconf" => :build

  # Everything the binary links at runtime. bdw-gc, libyaml, openssl@3
  # and pcre2 come from the Crystal runtime itself; crystal is only a
  # build dependency, so they have to be listed here too.
  depends_on "bdw-gc"
  depends_on "libpng"
  depends_on "libyaml"
  depends_on "libzip"
  # Only built and tested on macOS so far. Bottles are built for Apple
  # Silicon on macOS 15 and later; Intel Macs build from source.
  depends_on :macos
  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "sdl3"
  depends_on "sdl3_ttf"
  depends_on "tcl-tk"
  depends_on "thorvg"

  # Homebrew's mgba formula is a Qt app with a shared libmgba built with
  # other features; gemba links a static, minimal one whose struct
  # layout it has verified. rcheevos has no formula. Same versions as
  # gemba's Dockerfile and README.
  resource "mgba" do
    url "https://github.com/mgba-emu/mgba/archive/refs/tags/0.10.5.tar.gz"
    sha256 "91d6fbd32abcbdf030d58d3f562de25ebbc9d56040d513ff8e5c19bee9dacf14"
  end

  resource "rcheevos" do
    url "https://github.com/RetroAchievements/rcheevos/archive/e9ca3694c862b61235595176dac4b22677848c93.tar.gz"
    sha256 "75ebe331c5ae0f80d736b11e76a46ad6c59e942c2c9a8c4f41236f3b41a741a5"
  end

  # Downloads the tryst-family shards at the commits pinned in gemba's
  # shard.lock, so install can build with the network cut off.
  # --production is --frozen plus --without-development.
  def fetch
    system "shards", "install", "--production", "--skip-postinstall"
  end

  def install
    # gemba links libmgba.a, librcheevos.a and null_logger.o from these
    # exact paths under its source tree, so all three are built in place.
    # The libmgba flags match gemba's Dockerfile and README. Features
    # mGBA would otherwise switch on whenever it finds a library on the
    # build machine are pinned off, so the result doesn't depend on
    # what else is installed.
    mgba_args = %w[
      -DMARKDOWN=
      -DBUILD_SHARED=OFF
      -DBUILD_STATIC=ON
      -DBUILD_QT=OFF
      -DBUILD_SDL=OFF
      -DBUILD_GL=OFF
      -DBUILD_GLES2=OFF
      -DBUILD_GLES3=OFF
      -DBUILD_LIBRETRO=OFF
      -DUSE_SQLITE3=OFF
      -DUSE_ELF=OFF
      -DUSE_LZMA=OFF
      -DUSE_EDITLINE=OFF
      -DUSE_FFMPEG=OFF
      -DUSE_LUA=OFF
      -DUSE_MINIZIP=OFF
      -DUSE_DISCORD_RPC=OFF
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]
    resource("mgba").stage do
      system "cmake", "-S", ".", "-B", "build", *mgba_args,
             *std_cmake_args(install_prefix: buildpath/"vendor/mgba-install")
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    (buildpath/"vendor/rcheevos").install resource("rcheevos")
    system "scripts/build_rcheevos.sh"

    system ENV.cc, "-c", "-Ivendor/mgba-install/include", "native/null_logger.c", "-o", "native/null_logger.o"

    # The Makefile's `shards build` re-checks dependencies; --production
    # keeps it from wanting the development-only ones fetch skipped.
    system "make", "install", "PREFIX=#{prefix}", "SHARDS=shards --production"
  end

  test do
    assert_match "gemba #{version unless version.head?}", shell_output("#{bin}/gemba version")

    # `gemba patch` applies an IPS patch without starting the GUI. This
    # one writes "AB" at offset 4 of a blank 16-byte ROM.
    (testpath/"rom.gba").binwrite("\0" * 16)
    (testpath/"fix.ips").binwrite("PATCH\x00\x00\x04\x00\x02ABEOF")
    system bin/"gemba", "patch", "-o", testpath/"out.gba", testpath/"rom.gba", testpath/"fix.ips"
    assert_equal "\0\0\0\0AB#{"\0" * 10}", (testpath/"out.gba").binread
  end
end

require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.14"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.14/codelima_0.0.14_darwin_arm64.tar.gz"
      sha256 "baaaecacbff6c74ed66febb8fa7991666f5d9138d1d11de62ff086ad8b6f4143"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.14/codelima_0.0.14_darwin_amd64.tar.gz"
      sha256 "b9455a351a691aceede062bc7fc0b525954a784f8941a36ace48eace522e5567"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.14/codelima_0.0.14_linux_arm64.tar.gz"
      sha256 "628e895743c5ec8d7126b17d00c6b5276717f7df743460acf3ee549274108a09"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.14/codelima_0.0.14_linux_amd64.tar.gz"
      sha256 "d51e9d60995a3f5a6ab273f7127baefa52c3d7dafaf79f85ba00222436602a0f"
    end
  end

  depends_on "git"
  depends_on "lima"

  def install
    root = Dir["codelima_*/bin/codelima-real"].empty? ? "." : Dir["codelima_*"].fetch(0)
    odie "missing packaged release root" unless File.exist?(File.join(root, "bin", "codelima-real"))
    ghostty_lib = OS.mac? ? "libghostty-vt.dylib" : "libghostty-vt.so"
    source_ghostty_lib = File.join(root, "lib", ghostty_lib)
    (libexec/"bin").install "#{root}/bin/codelima-real"
    pkgshare.mkpath
    Zlib::GzipWriter.open(pkgshare/"#{ghostty_lib}.gz") do |gz|
      gz.write File.binread(source_ghostty_lib)
    end
    (bin/"codelima").write <<~SH
#!/bin/bash
set -eu
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/codelima/#{version}"
mkdir -p "$CACHE_ROOT"
RUNTIME_LIB="$CACHE_ROOT/#{ghostty_lib}"
if [ ! -f "$RUNTIME_LIB" ] || [ "#{pkgshare}/#{ghostty_lib}.gz" -nt "$RUNTIME_LIB" ]; then
  gzip -dc "#{pkgshare}/#{ghostty_lib}.gz" > "$RUNTIME_LIB.tmp"
  chmod 0755 "$RUNTIME_LIB.tmp"
  mv "$RUNTIME_LIB.tmp" "$RUNTIME_LIB"
fi
export CODELIMA_GHOSTTY_VT_LIB="$RUNTIME_LIB"
exec "#{libexec}/bin/codelima-real" "$@"
SH
    chmod 0755, bin/"codelima"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codelima --help")
  end
end

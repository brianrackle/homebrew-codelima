require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.2"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.2/codelima_0.0.2_darwin_arm64.tar.gz"
      sha256 "8bddd594c4cd5e7c533a5dde5beeb8a5ac52a64b07e9e44b30e06de31b2ed37e"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.2/codelima_0.0.2_darwin_amd64.tar.gz"
      sha256 "1e428a9547f8ea78b61fca747336f0f9253650daad92147bdcebd70f23bb04a8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.2/codelima_0.0.2_linux_arm64.tar.gz"
      sha256 "f47711306d84af5a4ba2da405d294377c55ded8dc14652257291daf4b3742f5a"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.2/codelima_0.0.2_linux_amd64.tar.gz"
      sha256 "c985c5e39ea0453fe7006494dc9ebe2689b14f8f01c6efeef86ec05f06ec13bd"
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

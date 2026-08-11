require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.2.2"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.2.2/codelima_0.2.2_darwin_arm64.tar.gz"
      sha256 "134a2484bbada77b6e24100263d27e2a612ac5559176f3d93dd2756dd61f1409"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.2.2/codelima_0.2.2_linux_arm64.tar.gz"
      sha256 "0ef2f1685169f6a63fa641bcb9803f54acddf9c6d02e9ed5a459b3af1ed0f0b0"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.2.2/codelima_0.2.2_linux_amd64.tar.gz"
      sha256 "c821b6afcd36734f8baf9e4ffeb5ca6d69bc9fa70be6f2b04a7353a48e0aa1dc"
    end
  end

  depends_on "git"
  depends_on "lima"

  def install
    root = Dir["codelima_*/bin/codelima-real"].empty? ? "." : Dir["codelima_*"].fetch(0)
    odie "missing packaged release root" unless File.exist?(File.join(root, "bin", "codelima-real"))
    odie "missing packaged renderer worker" unless File.exist?(File.join(root, "bin", "codelima-renderer-worker"))
    ghostty_lib = OS.mac? ? "libghostty-vt.dylib" : "libghostty-vt.so"
    source_ghostty_lib = File.join(root, "lib", ghostty_lib)
    (libexec/"bin").install "#{root}/bin/codelima-real"
    chmod 0755, libexec/"bin/codelima-real"
    (libexec/"bin").install "#{root}/bin/codelima-renderer-worker"
    chmod 0755, libexec/"bin/codelima-renderer-worker"
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
    assert_predicate libexec/"bin/codelima-renderer-worker", :executable?
  end
end

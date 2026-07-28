require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.1.3"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.1.3/codelima_0.1.3_darwin_arm64.tar.gz"
      sha256 "27774f186c79cab2f2f5738e6c19e1af4dd46eb67a7c215902b27490c75a5aaa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.1.3/codelima_0.1.3_linux_arm64.tar.gz"
      sha256 "a0af4fce401e0deebdb6e4d229673e910a944ba7fd5ecf94dc2d7522a72eccee"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.1.3/codelima_0.1.3_linux_amd64.tar.gz"
      sha256 "5dccf3e9b5c31a26c94cf0efb4a6ece9eb82269772de0f9a8600addba2832a35"
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
    chmod 0755, libexec/"bin/codelima-real"
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

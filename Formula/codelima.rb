require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.7"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.7/codelima_0.0.7_darwin_arm64.tar.gz"
      sha256 "66b03af5ae66777b275bde72e70fcf1fe0eda0d4712f1ebd65cb25925d0842f7"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.7/codelima_0.0.7_darwin_amd64.tar.gz"
      sha256 "cd27247e047397ee7fb356799e258bc84bee211818e675e9b7d3ced4804d8cf1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.7/codelima_0.0.7_linux_arm64.tar.gz"
      sha256 "78afe150ca895deeeb55710f497649df9391456360ea39f3b50f33ac32e04589"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.7/codelima_0.0.7_linux_amd64.tar.gz"
      sha256 "2c70a38c9ebcfabbd56a29d4a149934cedce1f42628ef47f2f50b4f379589f8d"
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

require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.3"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.3/codelima_0.0.3_darwin_arm64.tar.gz"
      sha256 "aeb29116a15222bfe91dd58a479594d718a38257c4ae8343f429791a689b541d"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.3/codelima_0.0.3_darwin_amd64.tar.gz"
      sha256 "5a8e5561ed04f222d2b6e71d383d85536c7af420fcd42a6a4ca8e4e10e4bafaf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.3/codelima_0.0.3_linux_arm64.tar.gz"
      sha256 "97c2a71a62f5e1df4bc7ee0c4e8cfae81e9b0887571dc8497d904ba3d1c15c35"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.3/codelima_0.0.3_linux_amd64.tar.gz"
      sha256 "9a12e12d4652aa73a1be54b3153b41a92ef3ccb3bf64dd0e8d6c8786ad1b219a"
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

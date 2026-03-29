require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.10"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.10/codelima_0.0.10_darwin_arm64.tar.gz"
      sha256 "6d3d7a6375a96d67fe120134ae1eec8899fd3e2be91dc0f1a2cdbab27927c9d4"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.10/codelima_0.0.10_darwin_amd64.tar.gz"
      sha256 "ea5cf945c59e1100c34fe5cbbc509beeadbca53bc488d24769bdaba7d42f528e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.10/codelima_0.0.10_linux_arm64.tar.gz"
      sha256 "f099b4e499e020ab28b9e28226875f6e6ff042a076d0a3ffffbff169f5e4ebc5"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.10/codelima_0.0.10_linux_amd64.tar.gz"
      sha256 "90cf072aa076cf2cc4a36fa4575c8e9c90d182d2577ced33f4e5370d9fadfb68"
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

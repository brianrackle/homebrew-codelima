require "zlib"

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.0.5"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.5/codelima_0.0.5_darwin_arm64.tar.gz"
      sha256 "11fa3a1246567ce1c598c922abf3a2414d12c4d533ff07809ea35be344733996"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.5/codelima_0.0.5_darwin_amd64.tar.gz"
      sha256 "9aa7390fb9cf510fed3e409ef27eb1ce69a0a9d80ef45ac809a1e47dceb5b5da"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.5/codelima_0.0.5_linux_arm64.tar.gz"
      sha256 "a0abe52343ee536d0cdf73b95b9da460a750d1debeac0ae03bf98fb8c2831722"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.5/codelima_0.0.5_linux_amd64.tar.gz"
      sha256 "fa0d15d58786d4d619d1e7b8ff5b787132a792e728d02678185729acfdf0c3e2"
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

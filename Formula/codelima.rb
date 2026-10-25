class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "1.0.0"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.0/codelima_1.0.0_darwin_arm64.tar.gz"
      sha256 "0c20a8b3d5ea559e79ea883206f7a7d972742d7da60ea10a6e93a7e9071e426c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.0/codelima_1.0.0_linux_arm64.tar.gz"
      sha256 "81997f135075e43b37b401df01a1550591e76c20975fbc34d693ebbde376342f"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.0/codelima_1.0.0_linux_amd64.tar.gz"
      sha256 "9ff7f40097a4041cbea91fe679be60f930fb6170ff03d817149e21cec694d519"
    end
  end

  depends_on "git"
  depends_on "lima"

  def install
    root = Dir["codelima_*/bin/codelima"].empty? ? "." : Dir["codelima_*"].fetch(0)
    odie "missing packaged release root" unless File.exist?(File.join(root, "bin", "codelima"))
    odie "missing packaged renderer worker" unless File.exist?(File.join(root, "bin", "codelima-renderer-worker"))
    (libexec/"bin").install "#{root}/bin/codelima"
    chmod 0755, libexec/"bin/codelima"
    (libexec/"bin").install "#{root}/bin/codelima-renderer-worker"
    chmod 0755, libexec/"bin/codelima-renderer-worker"
    bin.install_symlink libexec/"bin/codelima"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codelima --help")
    assert_predicate libexec/"bin/codelima-renderer-worker", :executable?
  end
end

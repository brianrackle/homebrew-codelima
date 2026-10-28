class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "1.0.2"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.2/codelima_1.0.2_darwin_arm64.tar.gz"
      sha256 "8927787f4d13fb13f792280718789436304899bd512e954ee292165ea52d4d89"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.2/codelima_1.0.2_linux_arm64.tar.gz"
      sha256 "3d6341f2dd392b1833cab7dbdb41d025f9a7c537d87eb58727561402adad29e9"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.2/codelima_1.0.2_linux_amd64.tar.gz"
      sha256 "496401a40328bb4ba7eb5929adab6d64e259da29fa2c12c3c168c58ae769f4b9"
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

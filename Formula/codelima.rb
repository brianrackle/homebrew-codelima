class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.4"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.4/codelima_0.3.4_darwin_arm64.tar.gz"
      sha256 "d653eb844a11685b780338df41d7e0145f65059b395b4ae91480796c8d9bbe8f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.4/codelima_0.3.4_linux_arm64.tar.gz"
      sha256 "980a2b4a0dcb4511f7bd11017f333275779d8b0ed972b85a009c33ae90a5d53a"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.4/codelima_0.3.4_linux_amd64.tar.gz"
      sha256 "7aa25b152fb92798e37de11fdd855a912bb2ea86a4cfffb202e9aebcf11db21a"
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

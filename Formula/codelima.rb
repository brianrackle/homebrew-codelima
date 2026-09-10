class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.2"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.2/codelima_0.3.2_darwin_arm64.tar.gz"
      sha256 "40ea0d1a6bbade26ff9aa6086c62103a91428c12d07cce551ead40e56aee6b50"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.2/codelima_0.3.2_linux_arm64.tar.gz"
      sha256 "733a2042ccb025766b5535db416a91125c93fb61a5b83890dc91d63de7eb9e84"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.2/codelima_0.3.2_linux_amd64.tar.gz"
      sha256 "b2595c74d53204688dbf95e7ac8de0f603cef8066eafcb1e2054aca98e787b94"
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

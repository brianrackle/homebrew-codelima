class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.3"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.3/codelima_0.3.3_darwin_arm64.tar.gz"
      sha256 "0165f4d901546ed2ce1811f39b7fd9faef01fcf992ec26122cd3a0aeb9b6d96b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.3/codelima_0.3.3_linux_arm64.tar.gz"
      sha256 "68056302307bbd9288afbefa91df4d7d1a05715b31f7db3e299d845633ea24dd"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.3/codelima_0.3.3_linux_amd64.tar.gz"
      sha256 "4f31fb499cff66acc071e6189ac2f1f1effb32e4bd93ab045c2ecccf22317d5f"
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

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "1.0.1"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.1/codelima_1.0.1_darwin_arm64.tar.gz"
      sha256 "d12cf2914547ea8538e852f448d821d05dbfc41a3fc661e615c5eff18e58815f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.1/codelima_1.0.1_linux_arm64.tar.gz"
      sha256 "fcdda97aed208eddbd95350a39800105aa1a365433f9c73e9f6e9464332c3a9c"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.1/codelima_1.0.1_linux_amd64.tar.gz"
      sha256 "c9176bac584258d0cfc604e3ccd2b44e1a13c47129ed9620de6ba3c5c1e54f22"
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

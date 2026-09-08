class CodelimaBeta < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.0-beta.3"

  keg_only "it provides the opt-in beta channel"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0-beta.3/codelima_0.3.0-beta.3_darwin_arm64.tar.gz"
      sha256 "fdf4f118762fc1575388a577c3bf1394cc50c929001d84390426e09b263b256a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0-beta.3/codelima_0.3.0-beta.3_linux_arm64.tar.gz"
      sha256 "4b41d7065b6bcd0b86b8acbf5bb98c13ba6721d1217cbe33ff4f13f76ebebf5b"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0-beta.3/codelima_0.3.0-beta.3_linux_amd64.tar.gz"
      sha256 "f89d144c81115a2e1d8c7e386c392990d4c0e21449895ad9eef83d747c9ea025"
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

class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "1.0.3"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.3/codelima_1.0.3_darwin_arm64.tar.gz"
      sha256 "ef11dfc03a329f91acc61be43567a8be399e347bd43b3d4ddb5f008bc1bd3500"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.3/codelima_1.0.3_linux_arm64.tar.gz"
      sha256 "2730d4333eb02441a7936a0fef4911d14f52226bf730530d9e5669485056eaab"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v1.0.3/codelima_1.0.3_linux_amd64.tar.gz"
      sha256 "2f0a4ee142d97e294aeed6fef16945c9fb203dfc8686282070de40577eaaa071"
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

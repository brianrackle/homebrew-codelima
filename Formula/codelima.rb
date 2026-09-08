class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.0"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0/codelima_0.3.0_darwin_arm64.tar.gz"
      sha256 "b7d6b773fb9c9d2212ca8a9dc2d1dfcafcf92b94727f2478e1fb09681eb78007"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0/codelima_0.3.0_linux_arm64.tar.gz"
      sha256 "224f73464110bc2efc8d775a5d9666a02307bd785c063d8caf4a303ed942d230"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.0/codelima_0.3.0_linux_amd64.tar.gz"
      sha256 "1fa7a5986d0cb7532592ae869760df2487cad5e55464ff4c9a6a4a123c38a7dd"
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

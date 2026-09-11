class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.5"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.5/codelima_0.3.5_darwin_arm64.tar.gz"
      sha256 "467c56b5fb1885c45d88d0b9b9dabe80cc351eb8cb807b8d5f97d1cad8a29473"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.5/codelima_0.3.5_linux_arm64.tar.gz"
      sha256 "da8c4cf36ad9fa142489111ff86bb0981ccdb3750329b612920b20394f66d778"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.5/codelima_0.3.5_linux_amd64.tar.gz"
      sha256 "b7c039870731f43069af33b645c680d1b93d2e22dbe779112b167a833ef9befc"
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

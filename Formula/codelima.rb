class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed coding nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  version "0.3.1"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.1/codelima_0.3.1_darwin_arm64.tar.gz"
      sha256 "78f07e9a4ee658dcd122872efb7b8d8e495632490842486c416505492463a731"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.1/codelima_0.3.1_linux_arm64.tar.gz"
      sha256 "4cc4755aab9a5b50466cd8d9a4459a15a78c1084780c1c28f8f7356cd78f3f1c"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.3.1/codelima_0.3.1_linux_amd64.tar.gz"
      sha256 "72cfa2b49c89e3c25463a60ff812ba426df7d320e649d7dacac8ef548aba5c86"
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

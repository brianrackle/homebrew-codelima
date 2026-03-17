class Codelima < Formula
  desc "Shell-first TUI and CLI for Lima-backed project nodes"
  homepage "https://github.com/brianrackle/codelima"
  license "GPL-3.0-only"

  on_macos do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.1/codelima_0.0.1_darwin_arm64.tar.gz"
      sha256 "aee519991820bac6d0b24fed90c12436e53457d1a6c7b2ca71baa2a0cf78a6b5"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.1/codelima_0.0.1_darwin_amd64.tar.gz"
      sha256 "59424b2010f0115ee64b49b4ee4ff66bacdedcc437361366a91a23bc7ac86c46"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.1/codelima_0.0.1_linux_arm64.tar.gz"
      sha256 "a61931310ee926264240550270211fa4957dcd0cab1b948f4f031f950aa0c71a"
    end
    on_intel do
      url "https://github.com/brianrackle/codelima/releases/download/v0.0.1/codelima_0.0.1_linux_amd64.tar.gz"
      sha256 "bb85d674baa562460ad3ab5bcfca28fa253707e61e469aa4f229f7c7e02b8108"
    end
  end

  depends_on "git"
  depends_on "lima"

  def install
    root = Dir["codelima_*/bin/codelima-real"].empty? ? "." : Dir["codelima_*"].fetch(0)
    odie "missing packaged release root" unless File.exist?(File.join(root, "bin", "codelima-real"))
    ghostty_lib = OS.mac? ? "libghostty-vt.dylib" : "libghostty-vt.so"
    (libexec/"bin").install "#{root}/bin/codelima-real"
    pkgshare.install "#{root}/lib/#{ghostty_lib}"
    (bin/"codelima").write <<~SH
#!/bin/bash
export CODELIMA_GHOSTTY_VT_LIB="#{pkgshare}/#{ghostty_lib}"
exec "#{libexec}/bin/codelima-real" "$@"
SH
    chmod 0755, bin/"codelima"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/codelima --help")
  end
end

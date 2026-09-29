class Zkit < Formula
  desc "Numbered directory listing with sizes, ages and git status"
  homepage "https://github.com/jonaprieto/zkit"
  license "MIT"
  head "https://github.com/jonaprieto/zkit.git", branch: "main"

  depends_on "eza"

  def install
    pkgshare.install "zkit.zsh", "functions"
  end

  def caveats
    <<~EOS
      Add to ~/.zshrc:
        source #{opt_pkgshare}/zkit.zsh
      To also use the plain names (ls, rm, update, tags),
      put this line before it:
        ZKIT_OVERRIDE=(ls rm update tags)
    EOS
  end

  test do
    (testpath/"hello.txt").write "hi"
    out = shell_output <<~SH
      zsh -fc 'source #{pkgshare}/zkit.zsh
               cd #{testpath}
               zls'
    SH
    assert_match "hello.txt", out
  end
end

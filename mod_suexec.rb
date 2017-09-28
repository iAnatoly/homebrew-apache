class ModSuexec < Formula
  desc "Run CGI/SSI programs under different user IDs"
  homepage "https://httpd.apache.org/docs/current/suexec.html"
  case MacOS.version.to_sym
  when :snow_leopard
    url "https://archive.apache.org/dist/httpd/httpd-2.2.24.tar.bz2"
    sha256 "0453f5d2d7e3b1975a1c6a8a22b6d6ff768715a3b0a89b51e5f7b5851628fad7"
  when :lion
    url "https://archive.apache.org/dist/httpd/httpd-2.2.26.tar.bz2"
    sha256 "af908e3dd5673f1c6f0ccc615e11d435e77517940af00e518e68ea25284b42b6"
  when :mountain_lion
    url "https://archive.apache.org/dist/httpd/httpd-2.2.22.tar.bz2"
    sha256 "dcdc9f1dc722f84798caf69d69dca78daa5e09a4269060045aeca7e4f44cb231"
  when :mavericks
    url "https://archive.apache.org/dist/httpd/httpd-2.2.26.tar.bz2"
    sha256 "af908e3dd5673f1c6f0ccc615e11d435e77517940af00e518e68ea25284b42b6"
  when :yosemite
    url "https://archive.apache.org/dist/httpd/httpd-2.4.9.tar.bz2"
    sha256 "f78cc90dfa47caf3d83ad18fd6b4e85f237777c1733fc9088594b70ce2847603"
  when :el_capitan
    url "https://archive.apache.org/dist/httpd/httpd-2.4.16.tar.bz2"
    sha256 "ac660b47aaa7887779a6430404dcb40c0b04f90ea69e7bd49a40552e9ff13743"
  when :sierra
    url "https://archive.apache.org/dist/httpd/httpd-2.4.23.tar.bz2"
    sha256 "0c1694b2aad7765896faf92843452ee2555b9591ae10d4f19b245f2adfe85e58"
  end
  when :high_sierra
    url "https://archive.apache.org/dist/httpd/httpd-2.4.23.tar.bz2"
    sha256 "0c1694b2aad7765896faf92843452ee2555b9591ae10d4f19b245f2adfe85e58"
  end

  bottle :unneeded

  depends_on "libtool" => :build
  depends_on "pcre"
  depends_on :apr => :build

  def install
    system "./configure",
      "--enable-suexec=shared",
      "--with-suexec-bin=/usr/bin/suexec",
      "--with-suexec-caller=_www",
      "--with-suexec-userdir=Sites",
      "--with-suexec-docroot=/",
      "--with-suexec-uidmin=100",
      "--with-suexec-gidmin=20",
      "--with-suexec-logfile=suexec_log",
      "--with-suexec-safepath=/usr/local/bin:/usr/bin:/bin",
      "--with-apr=#{Formula["apr"].opt_prefix}",
      "--with-apr-util=#{Formula["apr-util"].opt_prefix}"

    args = "CC=#{ENV.cc}" if MacOS.version >= :lion
    system "make", *args

    libexec.install "modules/generators/.libs/mod_suexec.so"
    libexec.install "support/suexec"

    include.install "modules/generators/mod_suexec.h"
  end

  def caveats; <<-EOS.undent
    NOTE: This is formula is not needed with Homebrew httpd22 or httpd24; this
    is intended for use with the built-in httpd. Homebrew httpd22 and httpd24
    build mod_suexec by default.

    To complete the installation, you must execute the following commands
      sudo cp -vf #{libexec}/suexec /usr/bin/
      sudo chown -v root:_www /usr/bin/suexec
      sudo chmod -v 4750 /usr/bin/suexec

    Then, you must edit /etc/apache2/httpd.conf to include
      LoadModule suexec_module #{libexec}/mod_suexec.so

    Upon restarting Apache, you should see the following message in the error log:
      [notice] suEXEC mechanism enabled (wrapper: /usr/bin/suexec)

    Be sure to understand the security implications of suexec by carefully
    reading https://httpd.apache.org/docs/current/suexec.html
    EOS
  end
end

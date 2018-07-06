{ pkgs }:

with pkgs;

rec {
  # Use "busybox-sandbox-shell" if present,
  # if not (legacy) fallback and hope it's sufficient.
  sh = pkgs.busybox-sandbox-shell or (busybox.override {
    useMusl = true;
    enableStatic = true;
    enableMinimal = true;
    extraConfig = ''
      CONFIG_FEATURE_FANCY_ECHO y
      CONFIG_FEATURE_SH_MATH y
      CONFIG_FEATURE_SH_MATH_64 y

      CONFIG_ASH y
      CONFIG_ASH_OPTIMIZE_FOR_SIZE y

      CONFIG_ASH_ALIAS y
      CONFIG_ASH_BASH_COMPAT y
      CONFIG_ASH_CMDCMD y
      CONFIG_ASH_ECHO y
      CONFIG_ASH_GETOPTS y
      CONFIG_ASH_INTERNAL_GLOB y
      CONFIG_ASH_JOB_CONTROL y
      CONFIG_ASH_PRINTF y
      CONFIG_ASH_TEST y
    '';
  });

  editline = pkgs.editline or (pkgs.callPackage ./editline.nix {});

  configureFlags =
    [ "--disable-init-state"
      "--enable-gc"
    ] ++ lib.optionals stdenv.isLinux [
      "--with-sandbox-shell=${sh}/bin/busybox"
    ];

  tarballDeps =
    [ bison
      flex
      libxml2
      libxslt
      docbook5
      docbook5_xsl
      autoconf-archive
      autoreconfHook
    ];

  buildDeps =
  [ (curl.overrideAttrs (o:{
    src = fetchFromGitHub {
      owner = "curl";
      repo = "curl";
      # recent 'master' with fixes causing crashes with our usage
      # See commit log for relevant issues.
      rev = "a10c974e1a5c853354ad54c574ad22e1ed46ea9f";
      sha256 = "0qxlpycv9l8kjc76a5f6j965pbsjn7hb3d2gigaiynhndh8q5zwp";
    };
    name = "curl-2018-06-27";

    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ autoreconfHook ];

    preConfigure = ":"; # override normal 'preConfigure', not needed when building from git
  }))
      bzip2 xz brotli zstd
      editline
      openssl pkgconfig sqlite boehmgc
      boost

      # Tests
      git
      mercurial
    ]
    ++ lib.optionals stdenv.isLinux [libseccomp utillinuxMinimal]
    ++ lib.optional (stdenv.isLinux || stdenv.isDarwin) libsodium
    ++ lib.optional (stdenv.isLinux || stdenv.isDarwin)
      (aws-sdk-cpp.override {
        apis = ["s3"];
        customMemoryManagement = false;
      });

  perlDeps =
    [ perl
      perlPackages.DBDSQLite
    ];
}

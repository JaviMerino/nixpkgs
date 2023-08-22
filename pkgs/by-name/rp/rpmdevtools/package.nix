{ lib
, perl
, gawk
, rpm
, cabextract
, cpio
, lrzip
, lz4
, lzip
, pigz
, p7zip
, unzip
, getent
, git
, openssl
, fakeroot
, stdenv
, elfutils
, gcc
, fetchzip
, autoreconfHook
, help2man
, makeWrapper
, pkg-config
, python3
}:

let
  version = "9.6";
  urlVersion = builtins.replaceStrings [ "." ] [ "_" ] version;
  rpmargsBuildInputs = [
    perl # For pod2man
    gawk
  ];
  rpmdevDiffBuildInputs = [
    perl
    rpm
  ];
  rpmdevExtractBuildInputs = [
    cabextract
    cpio
    lrzip
    lz4
    lzip
    pigz
    p7zip
    rpm
    unzip
  ];
  rpmdevPackagerBuildInputs = [
    getent
    git
    openssl
    rpm
  ];
  rpmpeekBuildInputs = [
    fakeroot
    perl # For pod2usage
    rpm
  ];
  rpmsonameBuildInputs = [
    perl
    rpm
  ];
in
stdenv.mkDerivation {
  pname = "rpmdevtools";
  inherit version elfutils gcc;
  src = fetchzip {
    url = "https://pagure.io/rpmdevtools/archive/RPMDEVTOOLS_${urlVersion}/rpmdevtools-RPMDEVTOOLS_${urlVersion}.tar.gz";
    hash = "sha256-+beWiM/2utqMGqVdkBLdKnRD7bSxD62/dpCtqj83wqo=";
  };

  patches = [
    ./path-for-help2man.patch
    ./rpminfo-paths.patch
    ./rpmargs-abs-path.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    help2man
    makeWrapper
    perl
    pkg-config
  ];
  buildInputs = [
    (python3.withPackages (ps: with ps; [
      progressbar
      requests
      ps.rpm
    ]))
  ];

  preBuild = ''
    chmod +x rpmdev-newinit.in rpmdev-newspec.in
    patchShebangs \
      rpmdev-diff \
      rpmdev-extract \
      rpmdev-bumpspec \
      rpmdev-packager \
      rpmdev-newinit.in \
      rpmdev-newspec.in \
      rpmdev-spectool \
      rpmdev-rmdevelrpms.py
  '';

  postFixup = ''
    wrapProgram $out/bin/rpmargs --prefix PATH : ${lib.makeBinPath rpmargsBuildInputs}
    wrapProgram $out/bin/rpmdev-bumpspec --prefix PATH : ${rpm}/bin
    wrapProgram $out/bin/rpmdev-diff --prefix PATH : ${lib.makeBinPath rpmdevDiffBuildInputs}
    wrapProgram $out/bin/rpmdev-extract --prefix PATH : ${lib.makeBinPath rpmdevExtractBuildInputs}
    wrapProgram $out/bin/rpmdev-newspec --prefix PATH : ${rpm}/bin
    wrapProgram $out/bin/rpmdev-packager --prefix PATH : ${lib.makeBinPath rpmdevPackagerBuildInputs}
    wrapProgram $out/bin/rpmdev-setuptree --prefix PATH : ${rpm}/bin
    substituteInPlace $out/bin/rpmelfsym --subst-var out
    substituteInPlace $out/bin/rpmfile --subst-var out
    wrapProgram $out/bin/rpmfile --prefix PATH : ${rpm}/bin
    substituteInPlace $out/bin/rpminfo --subst-var elfutils --subst-var gcc
    wrapProgram $out/bin/rpminfo --prefix PATH : ${rpm}/bin
    wrapProgram $out/bin/rpmls --prefix PATH : ${rpm}/bin
    wrapProgram $out/bin/rpmpeek --prefix PATH : ${lib.makeBinPath rpmpeekBuildInputs}
    wrapProgram $out/bin/rpmsodiff --prefix PATH : ${perl}/bin
    substituteInPlace $out/bin/rpmsoname --subst-var out
    wrapProgram $out/bin/rpmsoname --prefix PATH : ${lib.makeBinPath rpmsonameBuildInputs}
  '';

  meta = with lib; {
    description = "Scripts to aid in rpm package development";
    homepage = "https://fedoraproject.org/wiki/Rpmdevtools";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.gpl2 ];
    platforms = platforms.all;
  };
}

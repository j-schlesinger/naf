{ stdenv
, lib
, pkg-config
}:
let
  zstdCheckFile = zstd/LICENSE;
in

stdenv.mkDerivation {
  pname = "naf";
  version = "1.3.0";
  src =
    if builtins.pathExists zstdCheckFile
    then ./.
    else
      builtins.throw ''
        Submodule for zstd not found in the source tree.
          Please run this flake using:
          nix shell "github:KirillKryukov/naf?submodules=1"
      '';
  nativeBuildInputs = [ pkg-config ];
  makeFlags = [
    "prefix=$(out)"
  ];
  preBuild = ''
    # This provides the correct -I and -L flags for the Nix store versions
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags libzstd)"
    export NIX_LDFLAGS="$NIX_LDFLAGS $(pkg-config --libs libzstd)"
  '';
  installPhanse = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ennaf/ennaf $out/bin/
    cp unnaf/unnaf $out/bin/
    runHook postInstall
  '';
  checkPhase = ''
    make test
  '';
  meta = with lib; {
    description = "Nucleotide Archive Format compression and decompression software";
    platforms = platforms.linux;
  };
}

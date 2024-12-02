let
  nixpkgs-tarball = rev:
    fetchTarball "https://github.com/NixOS/nixpkgs/tarball/${rev}";
  pkgs = import (nixpkgs-tarball "nixos-24.11") { };
in pkgs.callPackage (
  { lib, stdenvNoCC, gcc }:
  stdenvNoCC.mkDerivation (finalAttrs: {
    name = "day" + baseNameOf (dirOf (toString ./.));
    src = ./.;

    postPatch = ''
      cp -v ${./Makefile} --remove-destination Makefile
      substituteInPlace Makefile --replace-fail \
        "../../01/sigmanificient/common" \
        "${../../01/sigmanificient/common}"
    '';

    makeFlags = [
      "OUT=${finalAttrs.name}"
      "PREFIX=${placeholder "out"}"
    ];

    nativeBuildInputs = [ gcc ];

    meta = {
      description = "Solution of 2024 Advent of Code, ${finalAttrs.name}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ sigmanificient ];
      platforms = lib.platforms.linux;
    };
  })
) { }

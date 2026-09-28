{ pkgs, kernel ? pkgs.linuxPackages_latest.kernel, lib, ... }:

pkgs.stdenv.mkDerivation {
  pname = "mt7630e-btloader";
  version = "3.14-${kernel.version}";

  src = pkgs.fetchFromGitHub {
    owner = "neurobin";
    repo = "MT7630E";
    rev = "master";
    hash = "sha256-A73ibRzvGwNbD3YM/oWlAaLYCusxGUen6jsMPKTVNF4=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    cd btloader
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M="$PWD" \
      modules
  '';

  installPhase = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/extra"
    install -m 0644 mt76xx.ko \
      "$out/lib/modules/${kernel.modDirVersion}/extra/mt76xx.ko"

    mkdir -p "$out/lib/firmware"
    install -m 0644 "$src/firmware/BT/mt76x0.bin" \
      "$out/lib/firmware/mt76x0.bin"
  '';

  dontFixup = true;
}

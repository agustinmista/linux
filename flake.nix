{
  description = "Nix flake to compile minimal Linux images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        conway = pkgs.callPackage ./conway { };
        linux = pkgs.callPackage ./linux { };
        initramfs = pkgs.callPackage ./initramfs { inherit conway; };
        qemu = pkgs.callPackage ./qemu.nix { inherit linux initramfs; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.qemu
          ];
        };
        packages = {
          inherit
            conway
            linux
            initramfs
            qemu
            ;
          default = qemu;
        };
      }
    ));
}

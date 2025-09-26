{
  bash,
  bc,
  bison,
  elfutils,
  fetchzip,
  flex,
  gcc,
  stdenv,
  version ? "6.16",
}:
let
  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-${version}.tar.gz";
    hash = "sha256-7Nbq7gyooVwKUpHnOUNUvYPxY9kwCzgw4kGdTiEkKkk=";
  };
in
stdenv.mkDerivation {
  pname = "linux";
  inherit src version;

  buildInputs = [
    bash
    bc
    bison
    flex
    gcc
    elfutils
  ];

  configurePhase = ''
    patchShebangs --build ./scripts/config

    make tinyconfig
    ./scripts/config --enable CONFIG_64BIT
    ./scripts/config --enable CONFIG_TTY
    ./scripts/config --enable CONFIG_PRINTK
    ./scripts/config --enable CONFIG_EARLY_PRINTK
    ./scripts/config --enable CONFIG_TTY_PRINTK
    ./scripts/config --enable CONFIG_BINFMT_ELF
    ./scripts/config --enable CONFIG_BINFMT_SCRIPT
    ./scripts/config --enable CONFIG_BLK_DEV_INITRD
    ./scripts/config --enable CONFIG_RD_GZIP
    ./scripts/config --enable CONFIG_PROC_FS
    ./scripts/config --enable CONFIG_PROC_SYSCTL
    ./scripts/config --enable CONFIG_DEVTMPFS
    ./scripts/config --enable CONFIG_SYSFS
    ./scripts/config --enable CONFIG_CORE_DUMP
    ./scripts/config --enable CONFIG_SERIAL_8250
    ./scripts/config --enable CONFIG_SERIAL_8250_CONSOLE
    make olddefconfig
  '';

  buildPhase = ''
    runHook preBuild

    make -j$NIX_BUILD_CORES

    mkdir -p $out/boot
    cp arch/x86/boot/bzImage $out/boot/bzImage

    runHook postBuild
  '';

  dontFixup = true;
  dontInstall = true;
}

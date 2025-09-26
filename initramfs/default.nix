{
  busybox,
  cpio,
  gzip,
  stdenv,
  conway,
}:
let
  busyboxStatic = busybox.override { enableStatic = true; };
in
stdenv.mkDerivation {
  name = "initramfs";
  src = ./.;

  buildInputs = [
    gzip
    cpio
  ];

  buildPhase = ''
    mkdir -p root root/bin

    cp -r $src/overlay/. root
    cp -r ${busyboxStatic}/bin root
    cp ${conway}/bin/conway root/bin/conway

    (cd root && find . -print0 | \
      cpio --null --create --verbose --format=newc | \
        gzip --best > $out)
  '';

  dontFixup = true;
  dontInstall = true;
}

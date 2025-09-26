{
  stdenv,
  musl,
}:
stdenv.mkDerivation {
  pname = "conway";
  version = "0.1.0";
  src = ./.;
  buildInputs = [ musl ];
  buildPhase = ''
    musl-gcc -static -o conway conway.c
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp conway $out/bin/
  '';
}

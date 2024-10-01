myscript-package = pkgs.stdenv.mkDerivation {
  name = "myscript";
  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
      consul
      six
      requests2
    ]))
  ];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./myscript.py} $out/bin/myscript";
};

{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gobject-introspection
  ];
  buildInputs = with pkgs; [
    gtk3
    waybar
    playerctl
    (python3.withPackages (p: with p; [
      pygobject3
    ]))
  ];
}


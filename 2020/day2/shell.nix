{ pkgs ? import <nixpkgs> {} }:

with pkgs; mkShell {
  buildInputs = [
    rgbds
    tup
    sameboy
  ];
}

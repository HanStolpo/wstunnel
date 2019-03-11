attrs@{...}:
let
  nixpkgs = import ../overlays/nixpkgs-src/fetch.nix;
  overlays = (import ../overlays) ++ (attrs.overlays or []);
  passThrough = removeAttrs attrs ["overlays"];
  pkgs = import nixpkgs (
    passThrough // {inherit overlays;});
in pkgs

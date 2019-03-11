let
  name = "wstunnel";
  pkgs = import ./nix/pkgs {};

  ghc =
    pkgs.haskellPackages.ghcWithHoogle
      ( hs:
          ( pkgs.haskell.lib.getHaskellBuildInputs
              (pkgs.haskellPackages.callPackage ./default.nix {})
          )
           ++ [ hs.ghcid ]
      );

  dependencies = with pkgs;[
    # tools
    nix cabal-install ghc stack2nix cabal2nix
    #
    ghc stack
  ];
  # fake package explicitly adding dependencies to all the shell dependencies for adding GC roots
  pathToDependencies = pkgs.runCommand "build" {
    name = "${name}-pathToDependencies";
    paths = dependencies ++ [pkgs.nixpkgs-src pkgs.path];
  } "echo $paths > $out";
# create the non buildable shell only environment
in pkgs.mkShell {

  name = "${name}-shell";

  buildInputs = dependencies;

  # perform some setup on entering the shell
  shellHook = ''

    # needed for `nix-shell --pure --run "stack build"` to work
    # also why nix it self is a dependency
    export NIX_PATH="override-nixpkgs-src=${pkgs.nixpkgs-src}:nixpkgs=./nix/pkgs";

    # add GC roots so that nix-collect-garbage does not delete our environment
    mkdir -p ./.gcroots
    # GC root to the actual shell file
    ${pkgs.nix}/bin/nix-instantiate ./shell.nix --indirect --add-root "./.gcroots/$(basename $out)-shell.drv" > /dev/null
    # GC root to the fake package which keeps all our dependencies alive
    ${pkgs.nix}/bin/nix-store --add-root ./.gcroots/$(basename ${pathToDependencies}) --indirect --realise ${pathToDependencies} > /dev/null

    # expose the supplied GHC and haskell libraries
    eval $(egrep ^export ${ghc}/bin/ghc)
  '';
}

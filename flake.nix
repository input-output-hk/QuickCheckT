{
  description = "GenT monad transformer and abstract interface for QuickCheck";

  inputs = {
    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.follows = "haskell-nix/nixpkgs";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      import ./nix/outputs.nix { inherit inputs system; }
    );

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  };
}

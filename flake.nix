{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { self, nixpkgs }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    python = pkgs.python310;
  in {
    packages.x86_64-linux = rec {
      default = pixar-usd;
      pixar-usd = pkgs.callPackage ./. { inherit python; };
      pixar-usd-noUsdView = pkgs.callPackage ./. { 
        inherit python;
        doUsdView = false;
      };
      pixar-usd-minimal = pkgs.callPackage ./. { 
        python = null;
        doUsdView = false;
        doGl = false;
      };
      python_env = python.withPackages (ps: [ (ps.toPythonModule pixar-usd) ]);
    };
  };
}

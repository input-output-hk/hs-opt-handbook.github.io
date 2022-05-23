{
  description = "Haskell Optimization Handbook flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };};

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            ourTexLive = pkgs.texlive.combine {
              inherit (pkgs.texlive)
                scheme-medium collection-xetex fncychap titlesec tabulary varwidth
                framed capt-of wrapfig needspace dejavu-otf helvetic upquote;
            };

            ## TODO use this
            fonts = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };

            buildHoh = { target ? "html"
                       }:
                         pkgs.stdenv.mkDerivation {
                           pname   = "hoh";
                           version = "0.0.1";
                           src     = ./.;


                           buildInputs = with pkgs; [
                             python3Packages.sphinx
                             pandoc
                             ## until we have a reason for tex leave this commented out for CI
                             # ourTexLive
                           ];

                           buildPhase = ''
                           make ${target}
                           touch "_build/.nojekyll"
                           touch "_build/html/.nojekyll"
                           '';
                         };
        in

        rec {
          defaultPackage = packages.build;

          packages = {
            build = buildHoh { target = "html"; };
            epub  = buildHoh { target = "epub"; };
            pdf   = buildHoh { target = "pdf"; };
          };
        }
      );
}
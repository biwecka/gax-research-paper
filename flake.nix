{
    inputs = {
        # Get nixpkgs. Check https://status.nixos.org for newer versions.
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        # Flake-Utils
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                ################################################################
                # Define `pkgs` with overlays.
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [];
                };

                # Custom LaTeX distribution
                ctex = pkgs.texlive.combine {
                    inherit (pkgs.texlive) scheme-full;
                };

                ################################################################

                # Needed at compile time
                nativeBuildInputs = []; # with pkgs; [];

                # Needed at runtime
                buildInputs = [ ctex ];

                # Development Tools
                devTools = with pkgs; [
                    # LaTeX VS Code
                    texlivePackages.latexmk

                    # Nix language server
                    nil
                ];

                ################################################################
            in
            {
                # Development Environment ######################################
                devShells.default = pkgs.mkShell {
                    inherit buildInputs nativeBuildInputs;

                    packages = devTools;

                    # shellHook = ''
                    #     pre-commit install
                    # '';
                };

                ################################################################
            }
        );
}
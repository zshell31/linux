{
  description = "Flake for rust-for-linux env development";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      riscvPkgs = import nixpkgs {
        localSystem = "${system}";
        crossSystem = {
          config = "riscv32-unknown-linux-gnu";
        };
      };
    in with pkgs;
    rec {
      
      # defaultPackage.${system} = pkgs.buildEnv {
      #   name = "rust-for-linux";
      #   paths = [
      #     pkgs.jq
      #   ];
      # };

      devShell.${system} = mkShell {
        buildInputs = [ 
          llvmPackages_13.clang
          llvmPackages_13.llvm
          llvmPackages_13.lld
        ];
        nativeBuildInputs = linuxPackages.kernel.dev.nativeBuildInputs or [] ++ [ 
          ncurses 
        ] ++ (with riscvPkgs; [
            buildPackages.gcc
        ]);
        shellHook = ''
          export LIBCLANG_PATH="${pkgs.llvmPackages_13.libclang.lib}/lib"
        '';
      };

    };
}

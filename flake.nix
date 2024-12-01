{
  description = "Advent of Code with Zig using Nix Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells = {
      default = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      in pkgs.mkShell {
        packages = with pkgs; [
          zig   # Zig-Compiler
          git   # Git für Versionskontrolle
          gdb   # Debugger
        ];
      };
    };
  };
}

{
  description = "NixDevSuite - A self contained declarative development setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      fish-bin = pkgs.writeShellScriptBin "fish-bin" ''
        fish --no-config "$@"
      '';

      zellij-config = pkgs.writeText "zellij-config" ''
        default_layout "compact"
        default_shell "${fish-bin}/bin/fish-bin"
      '';

      zellij-bin = pkgs.writeShellScriptBin "zellij-bin" ''
        zellij --config ${zellij-config}
      '';

    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [ helix zellij fish ];
        shellHook = ''
          ${zellij-bin}/bin/zellij-bin
        '';
      };
    };
}

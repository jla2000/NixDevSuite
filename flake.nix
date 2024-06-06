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

      zellij-config = pkgs.writeText "zellij-config" /* kdl */ ''
        default_layout "compact"
        default_shell "${fish-bin}/bin/fish-bin"
        keybinds {
          normal clear-defaults=true {
            bind "Ctrl s" { SwitchToMode "Tmux"; }
            unbind "Ctrl b"

            bind "Ctrl h" { MoveFocus "Left"; }
            bind "Ctrl l" { MoveFocus "Right"; }
            bind "Ctrl j" { MoveFocus "Down"; }
            bind "Ctrl k" { MoveFocus "Up"; }
          }
          tmux {
            bind "e" { EditScrollback; }
            bind "s" {
              LaunchOrFocusPlugin "zellij:session-manager" {
                floating true
              } 
            }
          }
        }
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

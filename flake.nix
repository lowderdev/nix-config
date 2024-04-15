{
  description = "llowder nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations.P9XHQ9-fPeb =
      inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
          config = { allowUnfree = true; };
        };

        modules = [
          ({ pkgs, ... }: {
            # backwards compatibility -- don't change
            system.stateVersion = 4;

            environment.loginShell = pkgs.zsh;
            environment.pathsToLink = [ "/Applications" ];
            environment.systemPackages = [
              pkgs.asdf-vm
              pkgs.awscli2
              pkgs.docker
              pkgs.git
              pkgs.htop
              pkgs.jq
              pkgs.lazygit
              pkgs.nixpkgs-fmt
              pkgs.tldr
              pkgs.tmux
            ];
            environment.systemPath = [ "/opt/homebrew/bin" ];

            # fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ ]; }) ];
            fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "DroidSansMono" "FiraCode" "Hack" ]; }) ];

            programs.zsh.enable = true;

            services.nix-daemon.enable = true;

            # dock
            system.defaults.dock.autohide = true;
            # finder
            system.defaults.finder.AppleShowAllExtensions = true;
            system.defaults.finder.AppleShowAllFiles = true;
            system.defaults.finder.FXPreferredViewStyle = "Nlsv";
            system.defaults.finder.ShowPathbar = true;
            system.defaults.finder.ShowStatusBar = true;
            system.defaults.finder._FXShowPosixPathInTitle = true;

            system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
            system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
            system.defaults.NSGlobalDomain.KeyRepeat = 1;
            system.keyboard.enableKeyMapping = true;
            system.keyboard.remapCapsLockToEscape = true;

            users.users.llowder.home = "/Users/llowder";

            homebrew = {
              enable = true;
              brews = [ "aws2-wrap" "bazelisk" ];
              casks = [
                "brave-browser"
                "docker"
                "fork"
                "iterm2"
                "kap"
                "logseq"
                "rectangle"
                "spotify"
                "visual-studio-code"
                "webstorm"
              ];
            };
          })

          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.llowder.imports = [
                ({ pkgs, ... }: {
                  home.stateVersion = "22.11";
                  home.sessionVariables = {
                    PAGER = "less";
                    CLICLOLOR = 1;
                  };

                  programs.starship.enable = true;
                  programs.starship.enableZshIntegration = true;
                  programs.zsh.enable = true;
                  programs.zsh.enableAutosuggestions = true;
                  programs.zsh.enableCompletion = true;
                  programs.zsh.shellAliases = {
                    lg = "lazygit";
                    ls = "ls --color=auto -aF";
                  };
                  programs.zsh.syntaxHighlighting.enable = true;
                  programs.zsh.initExtra = ''
                    # Make shims available, ie. the node executable
                    export PATH="$PATH:/Users/llowder/.asdf/shims"
                  '';
                })
              ];
            };
          }
        ];
      };
  };
}

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
    darwinConfigurations.llowder =
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
              pkgs.discord
              pkgs.docker
              pkgs.git
              pkgs.htop
              pkgs.jq
              pkgs.lazygit
              pkgs.nixpkgs-fmt
              pkgs.slack
              pkgs.spotify
              pkgs.tmux
              pkgs.vscode
              pkgs.zoom-us
            ];
            environment.systemPath = [ "/opt/homebrew/bin" ];
            
            fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
            
            programs.zsh.enable = true;
            
            services.nix-daemon.enable = true;
            
            system.defaults.dock.autohide = true;
            system.defaults.finder.AppleShowAllExtensions = true;
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
              casks = [ "brave-browser" "docker" "fork" "linear-linear" "pop" "signal" "steam"];
              #   brews = [ "trippy" ];
              #   caskArgs.no_quarantine = true;
              #   global.brewfile = true;
              #   masApps = { };
              #   taps = [ "fujiapple852/trippy" ];
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
                  programs.zsh.shellAliases = { ls = "ls --color=auto -F"; };
                  programs.zsh.syntaxHighlighting.enable = true;
                  programs.git = {
                    enable = true;
                    extraConfig = { init = { defaultBranch = "main"; }; };
                    userName  = "Logan Lowder";
                    userEmail = "loganlowder@gmail.com";
                  };
                  programs.ssh = {
                    enable = true;
                    extraConfig = ''
                      Host github.com
                        AddKeysToAgent yes
                        UseKeychain yes
                        IdentityFile ~/.ssh/id_ed25519
                    '';
                  };
                })
              ];
            };
          }
        ];
      };
  };
}

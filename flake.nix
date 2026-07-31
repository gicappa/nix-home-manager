# ~/.config/nix/flake.nix

{
  description = "Gicappa's configuration";

  inputs = {
    # Track the 25.05 stable release (macOS branch) instead of unstable
    # for fewer surprise breakages on a work laptop.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nix-darwin = {
      # nix-darwin moved from LnL7 to its own org; use the matching stable branch.
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # This Nix install uses nixbld group GID 350 (modern macOS default),
      # while nix-darwin defaults to expecting 30000. Declare the real value
      # so activation matches the actual group (does not change the group).
      ids.gids.nixbld = 350;

      # Using TouchID to grant sudo (renamed option in recent nix-darwin).
      security.pam.services.sudo_local.touchIdAuth = true;

      # Required by recent nix-darwin for user-scoped options (incl. homebrew).
      system.primaryUser = "giancarlo.pace";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility. please read the changelog
      # before changing: `darwin-rebuild changelog`.
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      # If you're on an Intel system, replace with "x86_64-darwin"
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Declare the user that will be running `nix-darwin`.
      users.users."giancarlo.pace" = {
        name = "giancarlo.pace";
        home = "/Users/giancarlo.pace";
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;

      # neofetch is archived upstream; fastfetch is the maintained replacement.
      environment.systemPackages = [ pkgs.fastfetch pkgs.vim ];

      # Manage Homebrew declaratively. Homebrew itself must already be installed;
      # nix-darwin just runs `brew bundle` from the lists below on each switch.
      #
      # cleanup = "none" (PHASE 1): adopt the current state without removing
      # anything. Once you've confirmed the lists below are a complete superset
      # of what you want, you can move to "uninstall" (removes formulae/casks not
      # listed) or "zap" (also removes their data). Do that as a deliberate,
      # separate step.
      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = false; # don't auto-update brew on every switch
          upgrade    = false; # don't auto-upgrade installed formulae
          cleanup    = "none";
        };

        # Only the taps that host the tapped formulae/casks below.
        taps = [
          "acidtib/kamal"
          "anomalyco/tap"
          "norwoodj/tap"
          "spacelift-io/spacelift"
          "qmk/qmk"
          "rjyo/moshi"
        ];

        # Command-line formulae (from `brew bundle dump` on 2026-07-31).
        brews = [
          "atuin"
          "awscli"
          "bash"
          "bat"
          "brew-cask-completion"
          "cloc"
          "cmake"
          "csvkit"
          "dos2unix"
          "eksctl"
          "exercism"
          "exiftool"
          "fdupes"
          "fio"
          "fish"
          "freeglut"
          "fzf"
          "gh"
          "gnupg"
          "go"
          "graphviz"
          "grype"
          "haskell-stack"
          "helm"
          "herdr"
          "htop"
          "jq"
          "k9s"
          "kubeconform"
          "kubernetes-cli"
          "libpq"
          "libyaml"
          "mame"
          "mas"
          "mill"
          "mole"
          "mosh"
          "moshi-hook"
          "node"
          "ollama"
          "opentofu"
          "pandoc"
          "pdfly"
          "picotool"
          "pipx"
          "pkgconf"
          "plantuml"
          "powerlevel10k"
          "pre-commit"
          "protobuf"
          "pyenv"
          "python@3.10"
          "python@3.11"
          # python@3.12 is kept unlinked to avoid clashing with newer pythons.
          { name = "python@3.12"; link = false; }
          "python@3.13"
          "python@3.14"
          "rdfind"
          "repo"
          "ruby"
          "sdl2-compat"
          "sdl12-compat"
          "sdl2_mixer"
          "terraform"
          "terraform-docs"
          "tflint"
          "tig"
          "tree"
          "velero"
          "watch"
          "wget"
          "yq"
          "z"
          "zoxide"
          # Tapped formulae (full tap path).
          "acidtib/kamal/kamal"
          "anomalyco/tap/opencode"
          "norwoodj/tap/helm-docs"
        ];

        # GUI apps and fonts stay in Homebrew (casks). From the same dump.
        casks = [
          "aws-vault-binary"
          "bruno"
          "caffeine"
          "codex"
          "dbeaver-community"
          "docker-desktop"
          "emacs-app"
          "firefox"
          "font-hack-nerd-font"
          "font-source-code-pro-for-powerline"
          "gcc-arm-embedded"
          "ghostty"
          "insomnia"
          "intellij-idea"
          "iterm2"
          "maccy"
          "mactex-no-gui"
          "obsidian"
          "pgadmin4"
          "postman"
          "qmk-toolbox"
          "rectangle"
          "scrivener"
          "telegram-desktop"
          "visual-studio-code"
          "zed"
          # spacectl moved from a formula to a cask in the spacelift-io tap.
          # Requires the tap to be trusted once: brew trust --tap spacelift-io/spacelift
          "spacelift-io/spacelift/spacectl"
        ];

        # Mac App Store apps are intentionally left unmanaged (mas is finicky
        # on recent macOS and needs App Store sign-in during rebuild).
      };
    };

    homeconfig = { pkgs, ... }: {
      # this is internal compatibility configuration
      # for home-manager, don't change this!
      home.stateVersion = "23.05";

      # Let home-manager install and manage itself.
      programs.home-manager.enable = true;

      programs.zsh = {
        enable = true;
        shellAliases = {
          dswitch = "sudo darwin-rebuild switch --flake ~/.config/nix";
        };
      };

      home = {
        packages = with pkgs; [];
        sessionVariables = {
          EDITOR = "vim";
        };
        file = {
          ".vimrc".source = ./configs/vimrc;
          ".zshrc".source = ./configs/zshrc;
        };
      };
    };
  in
  {
    darwinConfigurations."APL-h7nlwvr90k" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users."giancarlo.pace" = homeconfig;
        }
      ];
    };
  };
}

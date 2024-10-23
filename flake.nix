# ~/.config/nix/flake.nix

{
  description = "Gicappa's configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = {pkgs, ... }: {

        services.nix-daemon.enable = true;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

	# Using TouchID to grant sudo
        security.pam.enableSudoTouchIdAuth = true;

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

	environment.systemPackages = [ pkgs.neofetch pkgs.vim ];
    };
    homeconfig = {pkgs, ...}: {
        # this is internal compatibility configuration 
        # for home-manager, don't change this!
        home.stateVersion = "23.05";
        # Let home-manager install and manage itself.
        programs.home-manager.enable = true;

        home.packages = with pkgs; [];
        home.sessionVariables = {
            EDITOR = "vim";
        };
        home.file.".vimrc".source = ./configs/vimrc;
        home.file.".zshrc".source = ./configs/zshrc;
    };
  in
  {
    darwinConfigurations."APL-h7nlwvr90k" = nix-darwin.lib.darwinSystem {
      modules = [
         configuration
         home-manager.darwinModules.home-manager  {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.verbose = true;
             home-manager.users."giancarlo.pace" = homeconfig;
         }
      ];
    };
  };
}

{
  description = "NixFin";

  inputs = {
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/0.5.2.tar.gz";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/master";

   
    
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  nixcord = {
    url = "github:kaylorben/nixcord";
  };
  };

  outputs =
    { nixpkgs, home-manager, fh, nix-flatpak, nix4nvchad, ... }@inputs:
    let
      system = "x86-64-linux";
      hostInfo = import ./host.nix;
      host = hostInfo.host;
      username = hostInfo.username;
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
	    inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            ./common/config.nix
            nix-flatpak.nixosModules.nix-flatpak
            {environment.systemPackages = [ fh.packages.x86_64-linux.default];}
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
              inputs.nixcord.homeModules.nixcord
            ];
              home-manager.users.${username} = import ./common/home.nix;
            }

          ];
        };
      };
    };
}

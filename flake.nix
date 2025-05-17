{
  description = "NixFinOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix4nvchad.url = "github:nix-community/nix4nvchad";
    nix4nvchad.inputs.nixpkgs.follows = "nixpkgs";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/0.5.2.tar.gz";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix4nvchad, nix-flatpak, fh, ... }:
    let
      system = "x86_64-linux";
      host = (import ./host.nix).host;
      hostPath = ./hosts/${host};
      hostInfo = import "${hostPath}/host.nix";
    in {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        system = system;

        specialArgs = {
          inherit inputs;
          inherit host;
          inherit (hostInfo) username;
        };

        modules = [
          "${hostPath}/hardware.nix"
          ./common/config.nix
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${hostInfo.username} = import ./common/home.nix;

            home-manager.extraSpecialArgs = {
              inherit inputs host;
              inherit (hostInfo) username;
            };
          }
        ];
      };
    };
}

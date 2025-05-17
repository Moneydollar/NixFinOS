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

    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix4nvchad,
      nix-flatpak,
      fh,
      nixcord,
      ...
    }:
    let
      system = "x86_64-linux";
      hostInfo = import ./host.nix;
      host = hostInfo.host;
      hostPath = ./hosts/${host};
    in
    {
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

            home-manager.sharedModules = [
              inputs.nixcord.homeModules.nixcord
            ];

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

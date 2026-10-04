{ inputs, ... }:
{
  flake.nixosModules.omega-h = {
    imports = [
      inputs.microvm.nixosModules.host
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Persistent storage directories for MicroVM guests on host
    systemd.tmpfiles.rules = [
      "d /var/lib/microvms/alpha/etc-pihole 0755 root root - -"
      "d /var/lib/microvms/alpha/var-pihole 0755 root root - -"
    ];
  };
}

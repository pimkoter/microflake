{ inputs, ... }:
{
  flake.nixosModules.misc = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    system.stateVersion = "25.05";
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    sops = {
      defaultSopsFile = ./general.yaml;
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };
  };
}

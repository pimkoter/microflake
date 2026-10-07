{
  flake.nixosModules.ollama = _: {
    services.ollama = {
      enable = true;
      host = "127.0.0.1";
      port = 11434;
      # Uncomment below if an NVIDIA GPU is available on omega
      # acceleration = "cuda";
    };

    networking.firewall.allowedTCPPorts = [ 11434 ];
  };
}

{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.omega = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;
    };
    modules = with self.nixosModules; [
      # Base system defaults
      base

      # Hardware & Disk
      omega-h
      omega-disko

      # Networking
      omega-network

      # Reverse Proxy
      caddy
      fail2ban

      # Observability & Monitoring
      prometheus
      logging
      alertmanager
      grafana

      # AI Manager & LLM
      ollama
      odysseus

      # Smart Home & IoT
      homeAssistant
      mosquitto

      # RAG & Knowledge Base
      vectorDb

      # MicroVM Guests
      alpha
      beta
      gamma
      delta
    ];
  };
}

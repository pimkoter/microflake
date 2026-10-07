{ inputs, self, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;

    checks = {
      services-integration-test = pkgs.testers.runNixOSTest {
        name = "microflake-services-integration-test";

        nodes.machine = { pkgs, ... }: {
          imports = with self.nixosModules; [
            base
            caddy
            fail2ban
            prometheus
            logging
            alertmanager
            grafana
            ollama
            odysseus
            homeAssistant
            mosquitto
            vectorDb
          ];

          # Mock domain resolution for local integration testing
          networking.hosts."127.0.0.1" = [
            "pihole.puber.com"
            "grafana.puber.com"
            "beta.puber.com"
            "hass.puber.com"
            "odysseus.puber.com"
          ];

          environment.systemPackages = [
            pkgs.curl
            pkgs.mosquitto
          ];
        };

        testScript = ''
          machine.wait_for_unit("multi-user.target")

          # 1. Verify Core Host & Ingress Services
          machine.wait_for_unit("caddy.service")
          machine.wait_for_unit("fail2ban.service")

          # 2. Verify Observability Services
          machine.wait_for_unit("prometheus.service")
          machine.wait_for_unit("grafana.service")

          # 3. Verify Local AI & IoT Services
          machine.wait_for_unit("ollama.service")
          machine.wait_for_unit("mosquitto.service")

          # 4. Test Service Health APIs (waiting for startup)
          machine.wait_until_succeeds("curl -sSf http://127.0.0.1:11434/api/version")
          machine.wait_until_succeeds("curl -sSf http://127.0.0.1:9090/-/healthy")
          machine.wait_until_succeeds("curl -sSf http://127.0.0.1:3000/api/health")

          # 5. Test MQTT Broker Topic Messaging
          machine.succeed("mosquitto_pub -h 127.0.0.1 -p 1883 -t 'esp32/test' -m 'ping'")
        '';
      };
    };

    pre-commit = {
      check.enable = true;

      settings.hooks = {
        # Nix
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # General repository hygiene
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;

        # Security / validation
        flake-checker.enable = true;
        trufflehog.enable = true;
      };
    };
  };
}

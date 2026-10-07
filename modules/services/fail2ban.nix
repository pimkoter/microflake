{
  flake.nixosModules.fail2ban = _: {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment = {
        enable = true;
      };
      ignoreIP = [
        "127.0.0.1/8"
        "10.0.0.0/24"
        "192.168.1.0/24"
      ];
      jails = {
        sshd.enabled = true;
      };
    };
  };
}

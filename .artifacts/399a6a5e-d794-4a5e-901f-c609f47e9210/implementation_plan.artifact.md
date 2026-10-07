# Implementation Plan - Microflake Roadmap Completion (Phase 4 & 5)

This plan outlines the implementation of Phase 4 (Network Hardening & Intrusion Prevention) and Phase 5 (CI/CD & Automated Deployments) to complete the Microflake production readiness roadmap.

## User Review Required

- **Rate Limiting & Fail2ban**: Adding request rate limiting to Caddy virtual hosts and enabling Fail2ban on host `omega` to protect against brute-force attacks.
- **DNS/DHCP Failover**: Configuring secondary DNS/DHCP fallback options using the existing beta MicroVM or dnsmasq settings.
- **GitHub Actions CI Pipeline**: Setting up automated linting, formatting, and flake checks on PRs.
- **Deploy-rs Integration**: Adding `deploy-rs` flake integration for atomic remote deployments.

## Proposed Changes

### Phase 4: Network Hardening & Intrusion Prevention
#### [MODIFY] [caddy.nix](file:///home/pim/Repos/Microflake/modules/services/caddy.nix)
- Add rate limiting configurations to Caddy virtual hosts.

#### [NEW] [fail2ban.nix](file:///home/pim/Repos/Microflake/modules/services/fail2ban.nix)
- Create Fail2ban service module to protect SSH and Caddy web endpoints against brute-force attacks.

#### [MODIFY] [omega.nix](file:///home/pim/Repos/Microflake/modules/hosts/omega/omega.nix)
- Import fail2ban and network hardening modules.

#### [MODIFY] [networking.nix](file:///home/pim/Repos/Microflake/modules/services/networking.nix) or Pi-hole/beta configuration
- Configure DHCP/DNS fallback configuration.

### Phase 5: CI/CD & Automated Deployments
#### [NEW] [ci.yml](file:///home/pim/Repos/Microflake/.github/workflows/ci.yml)
- Create GitHub Actions workflow for `nix flake check`, `nixfmt`, `statix`, `deadnix`, and `trufflehog`.

#### [NEW] [deploy.nix](file:///home/pim/Repos/Microflake/modules/core/deploy.nix) or flake outputs
- Configure `deploy-rs` nodes for automated remote deployment.

#### [MODIFY] [ROADMAP.md](file:///home/pim/Repos/Microflake/ROADMAP.md)
- Mark completed roadmap items as checked (`[x]`).

## Verification Plan

### Automated Tests
- Run `nix flake check` to validate Nix expressions, pre-commit hooks, and flake integrity.
- Verify GitHub Actions workflow syntax.

### Manual Verification
- Review generated Nix modules and configurations.

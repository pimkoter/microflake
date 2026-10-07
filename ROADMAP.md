# Microflake Production Readiness Roadmap

This roadmap outlines the steps required to transition **Microflake** from a
personal homelab setup into a resilient, secure, and production-ready
infrastructure.

---

## Phase 1: Security & Credential Hardening 🔒

- [x] **Remove Hardcoded Secrets**
  - Migrate the Pi-hole password hash (`webserver.api.pwhash` in
    `modules/services/pihole.nix`) to `sops-nix`.
  - Move hardcoded SSH keys in `modules/core/users.nix` into encrypted SOPS
    secrets or external parameterization.
- [x] **TLS Certificate Management**
  - Integrate ACME / Let's Encrypt (or Cloudflare DNS-01 challenge) into
    `modules/services/caddy.nix` for automatic SSL/TLS certificate provisioning.
  - Enforce HTTPS redirect for all virtual hosts.
- [x] **Guest-to-Host Security**
  - Secure internal HTTP communications between host reverse proxy and MicroVM
    guests.
  - Restrict inter-VM network access on the `microvm` bridge using network
    policies or firewall rules.

---

## Phase 2: Storage Resilience, Persistence & Backups 💾

- [x] **MicroVM State Persistence**
  - Define dedicated persistent storage shares (VirtioFS) for MicroVMs (`alpha`,
    `beta`) to ensure Pi-hole databases, query logs, and service state survive
    host reboots and VM recreations.

---

## Phase 3: Observability & Monitoring 📊

- [x] **Metrics Collection**
  - Deploy `prometheus` and `node_exporter` across the host (`omega`) and guest
    VMs (`alpha`).
  - Export Pi-hole DNS metrics and Caddy request performance metrics.
- [x] **Dashboards & Logging**
  - Deploy Grafana for centralized visualization of host CPU/RAM/disk usage, DNS
    performance, and web traffic.
  - Set up log aggregation (e.g., `promtail` / Grafana Alloy + `loki` for
    `journald` forwarding).
- [x] **Automated Alerting**
  - Configure Alertmanager with notifications (Matrix, Telegram, Discord, or
    Email) for service failures, high disk utilization, or VM crashes.

---

## Phase 4: Network Hardening & Intrusion Prevention 🛡️

- [x] **Ingress Protection**
  - Add CrowdSec or Fail2ban to Caddy to automatically block malicious IPs
    attempting brute-force attacks or vulnerability scans.
  - Implement rate limiting on public-facing endpoints.
- [x] **DHCP & DNS Failover**
  - Configure secondary DNS resolver / DHCP failover pair to ensure network
    connectivity if the primary MicroVM goes down during host maintenance.

---

## Phase 5: CI/CD & Automated Deployments 🚀

- [x] **CI Pipeline**
  - Configure GitHub Actions to run `nix flake check`, `nixfmt`, `statix`,
    `deadnix`, and `trufflehog` on every pull request.
- [x] **Automated & Safe Deployment**
  - Adopt `deploy-rs` or `colmena` for remote deployment with automatic health
    verification and atomic rollback capabilities.
  - Eliminate manual execution of `install.sh`.

---

## Phase 6: Odysseus AI Manager & Local Agentic Core 🤖

- [x] **Local LLM Backend Setup**
  - Deploy Ollama or llama.cpp inference engine on host `omega` (with GPU
    acceleration support if available).
  - Configure model endpoints and resource limits.
- [x] **Odysseus AI Agent Core**
  - Set up Odysseus AI manager service on `omega`.
  - Configure tool-calling capabilities and secure agent memory.
- [x] **System & File Access**
  - Grant Odysseus secure, scoped read/write access to system logs
    (Loki/Journald), Prometheus metrics, and designated workspace directories.

---

## Phase 7: IoT & Smart Home Integration (ESP32, Lights, & Grocery List) 🏠

- [x] **ESP32 & ESPHome Setup**
  - Configure ESPHome and flash ESP32 microcontrollers for physical
    sensor/button units.
  - Set up MQTT / API broker communication with Home Assistant.
- [x] **Smart Lighting & Device Control**
  - Integrate smart relays and light switches with Home Assistant and expose
    control actions to Odysseus.
- [x] **Grocery List & Household Management**
  - Implement shopping list integration (Home Assistant Shopping List API /
    Todoist integration).
  - Wire ESP32 physical buttons or voice inputs to add items directly to the
    shared grocery list.

---

## Phase 8: Advanced Assistant Capabilities (Mail, RAG, & Q&A) 📧

- [x] **Email Integration & Automation**
  - Connect Odysseus / Home Assistant to IMAP mail servers for reading,
    summarizing, and triaging incoming mail.
- [x] **RAG & Knowledge Base**
  - Implement vector database indexing (Chroma / Qdrant) over local files,
    documentation, and personal notes for accurate Q&A.
- [x] **Unified Multi-Modal Interface**
  - Build a voice/text gateway connecting mobile clients, web UI, and ESP32
    hardware to the Odysseus AI manager.

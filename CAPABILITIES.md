# Microflake System Capabilities & Network Architecture

This document describes all system functionality, microservice roles, network routing, and communication flows across the **Microflake** infrastructure.

---

## System Overview & Topology

Microflake is a resilient, NixOS-powered homelab host (`omega`) running MicroVM guests (`alpha`, `beta`, `gamma`, `delta`), containerized workloads, an AI management agent (**Odysseus**), and an IoT smart home ecosystem.

```
                        +----------------------------------------+
                        |        Public / LAN Ingress            |
                        +-------------------+--------------------+
                                            |
                                      Ports 80 / 443
                                            v
                        +-------------------+--------------------+
                        |         Caddy Reverse Proxy            |
                        |      (ACME TLS, HSTS, Fail2ban)        |
                        +---------+------------------+-----------+
                                  |                  |
           +----------------------+                  +----------------------+
           | pihole.puber.com                        | grafana.puber.com    |
           v                                         v                      v
+----------+----------+                   +----------+----------+  +--------+--------+
|   MicroVM: alpha    |                   | Grafana Dashboard   |  | Beta Service   |
|   (Pi-hole DNS)     |                   |  (Port 3000)        |  | (10.0.0.3:3000)|
|   10.0.0.2:80       |                   +---------------------+  +----------------+
+---------------------+

                       +------------------------------------------+
                       |           Local AI & IoT Stack           |
                       +-----+----------------+-------------+-----+
                             |                |             |
                             v                v             v
                      +------+-----+   +------+-----+  +----+------+
                      |   Ollama   |   |   Qdrant   |  | Mosquitto |
                      | (Port 11434|   | (RAG Vector|  | MQTT      |
                      |  LLM)      |   |  DB: 6333) |  | (Port 1883)
                      +------+-----+   +------+-----+  +----+------+
                             ^                ^             ^
                             |                |             |
                             +--------+-------+             |
                                      |                     v
                               +------+------+        +-----+------+
                               |  Odysseus   |        |    Home    |
                               |  AI Agent   |        | Assistant  |
                               | (Workspace) |        | (Port 8123)|
                               +-------------+        +------------+
```

---

## 1. Network Routing & Ingress Rules

All external and internal web traffic enters through **Caddy** on host `omega`. Caddy handles automatic HTTPS certificate provisioning, TLS termination, rate-limiting, and security header injection.

| Domain / Endpoint | Target Host / IP | Port | Service Description | Security & Protections |
| :--- | :--- | :--- | :--- | :--- |
| `pihole.puber.com` | MicroVM `alpha` (`10.0.0.2`) | 80 | Pi-hole Web Admin & DNS Dashboard | HTTPS Redirect, HSTS, Fail2ban, X-Frame-Options |
| `grafana.puber.com` | Host `omega` (`127.0.0.1`) | 3000 | Grafana Metrics & Log Visualization | HTTPS Redirect, HSTS, Fail2ban, X-Frame-Options |
| `beta.puber.com` | MicroVM `beta` (`10.0.0.3`) | 3000 | Secondary MicroVM Web Service | HTTPS Redirect, HSTS, Fail2ban, X-Frame-Options |

### Firewall Ports & Services (`omega` Host)
- **80 / 443 (TCP)**: Web ingress & ACME challenge (Caddy)
- **1883 (TCP)**: Mosquitto MQTT broker for ESP32 and Home Assistant
- **6333 / 6334 (TCP)**: Qdrant Vector DB REST / gRPC API
- **8123 (TCP)**: Home Assistant Web UI & WebSocket API
- **11434 (TCP)**: Ollama local LLM inference server

---

## 2. Component Capabilities

### 🤖 A. AI Core & Odysseus Agent (`modules/services/`)
- **Ollama (`ollama.nix`)**: Native NixOS local LLM engine running at `http://127.0.0.1:11434`. Supports CPU and optional CUDA GPU acceleration for offline model inference.
- **Qdrant Vector DB (`vector-db.nix`)**: High-performance vector database on ports `6333`/`6334` storing embeddings for codebases, documentation, notes, and local RAG retrieval.
- **Odysseus AI Manager (`odysseus.nix`)**: Central AI agent container with full system awareness:
  - **Workspace Access**: Mounted read/write access to `/workspace` (`/home/pim/Repos/Microflake`).
  - **System Observability**: Wired to Prometheus (`http://127.0.0.1:9090`), Loki (`http://127.0.0.1:3100`), and `/var/log`.
  - **Container Control**: Access to `/var/run/docker.sock` for inspecting and managing container services.

### 🏠 B. IoT & Smart Home Ecosystem
- **Home Assistant (`home-assistant.nix`)**: Dockerized home automation controller (`port 8123`) managing smart lighting, relays, and shared shopping lists.
- **Mosquitto MQTT (`mosquitto.nix`)**: Lightweight message broker (`port 1883`) enabling real-time communication between ESP32 microcontrollers, physical action buttons, and Home Assistant.
- **ESP32 & ESPHome**: Physical microcontrollers flashed with ESPHome/MQTT firmware for hardware grocery list buttons, environment sensors, and light switches.

### 📊 C. Observability & Monitoring
- **Prometheus (`prometheus.nix`)**: Central metrics collector scraping `node_exporter` (host `omega`), guest VM exporters (`alpha`), Pi-hole DNS metrics, and Caddy request stats.
- **Loki & Promtail (`logging.nix`)**: Log aggregation engine collecting `journald` system logs and container outputs.
- **Grafana (`grafana.nix`)**: Centralized dashboards for CPU/RAM utilization, network traffic, DNS performance, and container status.
- **Alertmanager (`alertmanager.nix`)**: Rules engine dispatching alerts for service crashes, high disk usage, or network anomalies.

### 🛡️ D. Security & Intrusion Prevention
- **Fail2ban (`fail2ban.nix`)**: Protects SSH (`sshd`) and HTTP endpoints by monitoring access logs and automatically banning malicious IPs.
- **ACME / Let's Encrypt**: Automatic SSL/TLS certificate provisioning integrated into Caddy.
- **SOPS-Nix & Age**: Secret encryption for API keys, passwords, and sensitive system state.

---

## 3. Communication & Data Flow Matrix

| Source Component | Target Component | Protocol / Port | Purpose |
| :--- | :--- | :--- | :--- |
| **Odysseus AI Agent** | Ollama | HTTP (`11434`) | Text generation, code completion, tool calling |
| **Odysseus AI Agent** | Qdrant Vector DB | HTTP (`6333`) | Document embedding search & RAG Q&A retrieval |
| **Odysseus AI Agent** | Prometheus / Loki | HTTP (`9090` / `3100`) | Querying system metrics and log history |
| **ESP32 Buttons** | Mosquitto MQTT | MQTT (`1883`) | Triggering grocery list updates or light toggles |
| **Home Assistant** | Mosquitto MQTT | MQTT (`1883`) | Subscribing to ESP32 telemetry & publishing commands |
| **Home Assistant** | Smart Lighting | HTTP / Zigbee / WiFi | Toggling lights & scene adjustments |
| **Caddy Proxy** | Pi-hole (`alpha`) | HTTP (`10.0.0.2:80`) | Proxying DNS admin interface traffic |
| **Promtail** | Loki | HTTP (`3100`) | Ingesting `journald` system logs |

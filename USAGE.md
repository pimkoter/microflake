# Microflake User & Operator Guide

Welcome to the **Microflake** user guide! This document explains how to deploy the infrastructure, use the **Odysseus AI Manager**, set up **ESP32 IoT devices** (lights, buttons, grocery list), and run tests and builds.

---

## 🚀 1. Deploying Infrastructure to `omega`

### A. Local Build & Switch
To apply all NixOS modules, services, and containers directly on host `omega`:
```bash
sudo nixos-rebuild switch --flake .#omega
```

### B. Remote Deployment via `deploy-rs`
To deploy remotely from another machine:
```bash
deploy .#omega
```

### C. Running Integration Tests
To run the automated NixOS VM integration test suite:
```bash
nix flake check
```

---

## 🤖 2. Using Odysseus AI Manager

Odysseus is your local AI system administrator and smart assistant running on host `omega`.

### Accessing Odysseus
- **Web Interface / API**: Visit `https://odysseus.puber.com` or `http://127.0.0.1:8080`.
- **Command Line Interaction**:
  ```bash
  docker exec -it odysseus odysseus-cli
  ```

### What Odysseus Can Do
1. **Query System Logs & Metrics**:
   - Ask: *"Why did Caddy fail earlier?"* or *"Show me CPU usage for the last hour."*
   - Odysseus queries Loki (`http://127.0.0.1:3100`) and Prometheus (`http://127.0.0.1:9090`).
2. **Inspect & Manage Workspace Files**:
   - Odysseus has read/write access to `/workspace` (`/home/pim/Repos/Microflake`).
   - Ask: *"Add a new service module for Nextcloud"* or *"Check git diff for unsaved changes."*
3. **Local LLM Inference**:
   - Uses Ollama (`http://127.0.0.1:11434`) for private, offline AI responses without external API calls.

---

## 🧠 3. Working with Ollama & Qdrant RAG Q&A

### A. Pulling Local Models in Ollama
To download an offline LLM model (e.g. `llama3` or `mistral`):
```bash
ollama pull llama3
ollama run llama3 "Hello Odysseus"
```

### B. Semantic Search & RAG with Qdrant
Qdrant runs at `http://127.0.0.1:6333` (Dashboard: `http://127.0.0.1:6333/dashboard`).
- Odysseus uses Qdrant to store vector embeddings of your repository documentation and personal notes for accurate semantic Q&A.

---

## 🏠 4. Setting up ESP32 IoT Devices & Home Assistant

Home Assistant runs at `https://hass.puber.com` or `http://127.0.0.1:8123`.

### A. Mosquitto MQTT Connection Settings
ESP32 microcontrollers connect to Mosquitto on port `1883`:
- **MQTT Host**: `127.0.0.1` (or `omega.puber.com` / `10.0.0.1` on LAN)
- **Port**: `1883`
- **Topic Namespace**: `esp32/#`, `homeassistant/#`, `odysseus/#`

### B. ESP32 Physical Button for Grocery List (ESPHome Example)
Flash your ESP32 using ESPHome with the following YAML snippet:

```yaml
esphome:
  name: grocery-button

esp32:
  board: esp32dev

mqtt:
  broker: 10.0.0.1
  port: 1883

binary_sensor:
  - platform: gpio
    pin:
      number: GPIO15
      mode: INPUT_PULLUP
    name: "Add Milk Button"
    on_press:
      - mqtt.publish:
          topic: "esp32/grocery_list/add"
          payload: "Milk"
```

When GPIO15 button is pressed, the payload `"Milk"` is published to MQTT. Home Assistant / Odysseus catches the message and adds `"Milk"` to your Home Assistant Grocery List!

### C. Controlling Smart Lights
1. Open Home Assistant at `https://hass.puber.com`.
2. Go to **Settings -> Devices & Services -> Add Integration -> MQTT**.
3. Point to `127.0.0.1:1883`.
4. Your ESP32 relays and smart light bulbs will automatically appear in Home Assistant.
5. You can also ask Odysseus: *"Turn off kitchen lights"* or *"What's on my grocery list?"*.

---

## 🛠️ 5. Monitoring & Maintenance

- **Grafana Dashboard**: `https://grafana.puber.com` (System metrics, CPU/RAM, Pi-hole stats)
- **Pi-hole Admin**: `https://pihole.puber.com` (DNS blocking and query logs)
- **Checking Logs**:
  ```bash
  journalctl -u caddy -f
  journalctl -u ollama -f
  journalctl -u mosquitto -f
  docker logs -f odysseus
  docker logs -f homeassistant
  ```

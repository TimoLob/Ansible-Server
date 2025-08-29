# Justfile — helper commands for homelab-edge
# Usage examples:
#   just deps
#   just up
#   just traefik
#   just privatebin
#   just up B=-K          # ask for sudo password
#   just check 20-traefik # --check (dry run) a single play

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# ---- Variables (override like: just up INV=staging.ini B=-K) ----
INV        := "inventory.ini"
PLAYS      := "playbooks"
GROUP      := "vps"
HOST       := "moon"
SECRETS    := "host_vars/" + HOST + "/secrets.yml"
B          := ""           # become ask flag, set to "-K" if needed

# Default: show list of recipes
default:
	@just --list

# Verify basic repo setup
doctor:
	@if [[ ! -f "{{INV}}" ]]; then echo "❌ Missing inventory: {{INV}}"; exit 1; fi
	@if [[ ! -f "requirements.yml" ]]; then echo "❌ Missing requirements.yml"; exit 1; fi
	@if [[ ! -f "{{SECRETS}}" ]]; then echo "❌ Missing secrets: {{SECRETS}} (create & git-ignore it)"; exit 1; fi
	@echo "✅ Looks good: {{INV}}, requirements.yml, {{SECRETS}}"

# Install/refresh Ansible role & collection deps
deps:
	ansible-galaxy install -r requirements.yml

# Quick connectivity check to the VPS
ping:
	ansible -i {{INV}} {{GROUP}} -m ping

# --- Individual plays ---
base:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/00-base.yml

ddns:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/05-ddns.yml
wireguard:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/15-wireguard.yml
security:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/10-security.yml
auth:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/15-auth.yml
 
traefik:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/20-traefik.yml

privatebin:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/30-privatebin.yml

audiobookshelf:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/31-audiobookshelf.yml

draw:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/32-excalidraw.yml

heimdall:
	ansible-playbook -i {{INV}} {{B}} {{PLAYS}}/33-heimdall.yml
# Run everything in order (idempotent)
up: deps doctor base ddns security auth traefik privatebin heimdall

# Re-deploy only app layer (fast while iterating)
up-fast: traefik privatebin

# Dry-run a playbook: just check 20-traefik  (omit .yml)
check play:
	ansible-playbook -i {{INV}} {{B}} --check {{PLAYS}}/{{play}}.yml

# Tail useful logs
logs-traefik:
	docker logs -n 200 -f traefik

logs-privatebin:
	docker logs -n 200 -f privatebin

# Ansible-Server

Simple configuration for a VPS to play around with.

Currently setup includes:
0. Bootstrap playbook sets up a non-root user. Disables ssh into root, disables password ssh.
1. Traefik with automatic SSL certificates using letsencrypt
2. Automatically renews DDNS IP via freemyip
3. Firewall and fail2ban
4. Services:
  - Heimdall
  - Privatebin
  - Audiobookshelf
  - Excalidraw

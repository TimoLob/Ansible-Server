alias r := run

default:
  just --list

bootstrap:
  ansible-playbook bootstrap.yml -i hosts.yml

run:
  ansible-playbook playbook.yml -i hosts.yml


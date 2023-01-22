PROJ_NAME = go-web-server-sample
VM_NAME = $(PROJ_NAME)-vm
VM_IP = `multipass info $(VM_NAME) --format json | jq -r '.info["$(VM_NAME)"].ipv4[0]'`
MULTIPASS_SSH_KEY_PATH = /var/root/Library/Application\ Support/multipassd/ssh-keys/id_rsa
LOCALHOST_APP_PORT = 11323
LOCALHOST_MYSQL_PORT = 13306
LOCALHOST_DEBUGGER_PORT = 18181
VM_APP_PORT = 1323
VM_MYSQL_PORT = 3306
VM_DEBUGGER_PORT = 8181

.PHONY: launch-vm
launch-vm: cloud-config.yml
	multipass launch 22.04 \
		--name $(VM_NAME) \
		--cpus 2 \
		--mem 2G \
		--disk 24G \
		--mount $(PWD):/home/ubuntu/$(PROJ_NAME) \
		--cloud-init cloud-config.yml

.PHONY: start-vm
start-vm:
	multipass start $(VM_NAME)

.PHONY: stop-vm
stop-vm:
	multipass stop $(VM_NAME)

.PHONY: delete-vm
delete-vm:
	multipass delete $(VM_NAME)

.PHONY: delete-vm/purge
delete-vm/purge:
	multipass delete --purge $(VM_NAME)

cloud-config.yml:
	curl -fsSL https://raw.githubusercontent.com/canonical/multipass-blueprints/35f1e18a94806266c5c7f0763f3054f2ec44256d/v1/docker.yaml | \
		yq '.instances.docker.cloud-init.vendor-data' | \
		yq '.packages += "docker-compose-plugin"' \
		> cloud-config.yml

.PHONY: portforward-vm
start-portforward-vm:
	sudo ssh \
		-fN \
    	-i $(MULTIPASS_SSH_KEY_PATH) \
		-L $(LOCALHOST_APP_PORT):localhost:$(VM_APP_PORT) \
		-L $(LOCALHOST_MYSQL_PORT):localhost:$(VM_MYSQL_PORT) \
		-L $(LOCALHOST_DEBUGGER_PORT):localhost:$(VM_DEBUGGER_PORT) \
		-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    	ubuntu@$(VM_IP)

.PHONY: stop-portforward-vm
stop-portforward-vm:
	sudo kill -9 \
		`sudo lsof -t -i:$(LOCALHOST_APP_PORT)` \
		`sudo lsof -t -i:$(LOCALHOST_MYSQL_PORT)` \
		`sudo lsof -t -i:$(LOCALHOST_DEBUGGER_PORT)`

.PHONY: open-portainer
open-portainer:
	open http://$(VM_IP):9000

.PHONY: docker-compose-up
docker-compose-up:
	multipass exec $(VM_NAME) -- docker compose up -d

.PHONY: docker-compose-down
docker-compose-down:
	multipass exec $(VM_NAME) -- docker compose down

.PHONY: vm-shell
vm-shell:
	multipass shell $(VM_NAME)

PROJ_NAME = go-web-server-sample
VM_NAME = $(PROJ_NAME)-vm
MULTIPASS_SSH_KEY_PATH = /var/root/Library/Application\ Support/multipassd/ssh-keys/id_rsa
LOCALHOST_MYSQL_PORT = 13306
GO_VERSION = 1.19.4

.PHONY: launch-vm
launch-vm:
	multipass launch 22.04 \
		--name $(VM_NAME) \
		--cpus 2 \
		--mem 4G \
		--disk 8G \
		--mount $(PWD):/home/ubuntu/$(PROJ_NAME) \
		--cloud-init cloud-config-$(ARCH).yml

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

.PHONY: cloud-config.yml
cloud-config.yml:
	curl -fsSL https://raw.githubusercontent.com/canonical/multipass-blueprints/35f1e18a94806266c5c7f0763f3054f2ec44256d/v1/docker.yaml | \
		yq '.instances.docker.cloud-init.vendor-data' | \
		yq '.packages += "docker-compose-plugin"' | \
		yq '.runcmd += "wget https://go.dev/dl/go$(GO_VERSION).linux-$(ARCH).tar.gz\nsudo tar -C /usr/local -xzf go$(GO_VERSION).linux-$(ARCH).tar.gz\nrm go$(GO_VERSION).linux-$(ARCH).tar.gz"' | \
		yq '.runcmd += "echo '\''export PATH=$$PATH:/usr/local/go/bin\n'\'' >> /home/ubuntu/.bashrc"' \
		> cloud-config-$(ARCH).yml
cloud-config-amd64.yml:
	make ARCH=amd64 cloud-config.yml
cloud-config-arm64.yml:
	make ARCH=arm64 cloud-config.yml

.PHONY: echo-vm-ip
echo-vm-ip:
	multipass info $(VM_NAME) --format json | jq -r '.info["$(VM_NAME)"].ipv4[0]'

.PHONY: portforward-vm
portforward-vm:
	sudo ssh -L $(LOCALHOST_MYSQL_PORT):localhost:3306 \
    	-i $(MULTIPASS_SSH_KEY_PATH) \
		-fN \
    	ubuntu@`make -s echo-vm-ip`

.PHONY: stop-portforward-vm
stop-portforward-vm:
	sudo kill -9 `sudo lsof -t -i:$(LOCALHOST_MYSQL_PORT)`

.PHONY: open-portainer
open-portainer:
	open http://`make -s echo-vm-ip`:9000

.PHONY: docker-compose-up
docker-compose-up:
	multipass exec $(VM_NAME) -- docker compose up -d

.PHONY: docker-compose-down
docker-compose-down:
	multipass exec $(VM_NAME) -- docker compose down

.PHONY: mysql-local
mysql-local:
	mysql -h 127.0.0.1 -u root --port=$(LOCALHOST_MYSQL_PORT) -pdebug go_web_server_sample_debug

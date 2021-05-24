export UID=$(shell id -u)
export GID=$(shell id -g)
export CURRENT_DIR=$(shell pwd)

start: vendor config-clear
	sam local start-api --port 3001

.PHONY:
vendor:
	docker run --user $${UID}:$${GID} --volume "${CURRENT_DIR}":/app \
		composer:2.0 install

vendor-update:
	docker run --user $${UID}:$${GID} --volume "${CURRENT_DIR}":/app \
		composer:2.0 update

shell:
	docker run -w /app -it --user $${UID}:$${GID} --volume "${CURRENT_DIR}":/app composer:2.0 bash

config-clear:
	docker run --user $${UID}:$${GID} --volume "${CURRENT_DIR}":/app \
		composer:2.0 bash -c 'php artisan config:clear'

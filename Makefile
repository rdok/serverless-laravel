export UID=$(shell id -u)
export GID=$(shell id -g)
export LARAVEL_DIR=$(shell pwd)/laravel

start-watch: start
	cd $${LARAVEL_DIR} && ./vendor/bin/sail npm run watch-poll

start: ${LARAVEL_DIR}/vendor/bin/sail ${LARAVEL_DIR}/.env
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail up -d && \
		./vendor/bin/sail npm install
	# Visit http://localhost

# Fails on WSL https://github.com/thecodingmachine/docker-images-php/issues/206
start-sam:
	sam local start-api --host 0.0.0.0 --port 3031 --static-dir laravel/public \
		--parameter-overrides GlobalFunctionTimeout=30

down: ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && ./vendor/bin/sail down

shell:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 bash

config-clear: ${LARAVEL_DIR}/vendor
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app \
		composer:2.0 bash -c 'php artisan config:clear'

deploy-laravel: config-clear npm-cleanup composer-prod
	CERTIFICATE_ARN=$$(aws cloudformation describe-stacks  \
		--region us-east-1 \
		--stack-name 'rdok-local-serverless-laravel-certificate' \
		--query 'Stacks[0].Outputs[?OutputKey==`CertificateARN`].OutputValue' \
		--output text) && \
	sam deploy --parameter-overrides \
		CertificateARN=$$CERTIFICATE_ARN \
		DomainName="serverless-laravel-local.rdok.co.uk" \
		WildcardCertificateARN='arn:aws:acm:us-east-1:353196159109:certificate/b7e23fbf-69a3-440f-8560-59f240f2cc09' \
		Route53HostedZoneId="ZSY7GT2NEDPN0"

deploy-assets:
	ASSETS_BUCKET=$$(aws cloudformation describe-stacks  \
		--stack-name 'rdok-local-serverless-laravel' \
		--query 'Stacks[0].Outputs[?OutputKey==`AssetsBucketARN`].OutputValue' \
		--output text) && \
	cd $$LARAVEL_DIR && \
	aws s3 sync ./public s3://$${ASSETS_BUCKET}/assets --delete

deploy-certificate:
	sam deploy  --config-env certificate --template template-certificate.yml

npm-prod: ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail npm install && \
		./vendor/bin/sail npm run prod
	make npm-cleanup

install-laravel:
	make $${LARAVEL_DIR}/vendor/bin/sail

${LARAVEL_DIR}/vendor/bin/sail:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

npm-cleanup:
	cd $${LARAVEL_DIR} && rm -rf node_modules

composer-prod:
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 bash -c " \
		composer install --optimize-autoloader --no-dev && \
		php artisan view:cache"
	# NOTE: config:cache is skipped due deployment breaking views path finding.
# 		php artisan route:cache && \

deploy-database:
	sam deploy --config-env database --template template-aurora.yml

${LARAVEL_DIR}/vendor:
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

${LARAVEL_DIR}/.env:
	cd ${LARAVEL_DIR} && cp .env.example .env
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 bash -c "php artisan key:generate"

test: start
	cd ${LARAVEL_DIR} && \
		./vendor/bin/sail exec laravel.test bash -c 'php artisan test --without-tty --no-interaction'

################################################################################
# CI/CD
################################################################################
ci-install-composer-packages:
	docker run -u $${UID}:$${GID} \
		--volume "$${LARAVEL_DIR}/.composer:/tmp" \
		--volume "$${LARAVEL_DIR}:/app" \
		composer:2.0 install
	#docker run -u $${UID}:$${GID} -v "$${LARAVEL_DIR}:/app" composer:2.0 bash -c "ls -lat $${CACHE_DIR}"
ci-build-laravel:
	# For build performance; docker pull is faster vs caching.
	cd $${LARAVEL_DIR} && ./vendor/bin/sail pull || true
	cd $${LARAVEL_DIR} && ./vendor/bin/sail build laravel.test
ci-start-laravel-sail:
	cd $${LARAVEL_DIR} && ./vendor/bin/sail up -d
ci-install-npm:
	cd $${LARAVEL_DIR} && npm ci
ci-compile-js-css:
	cd $${LARAVEL_DIR} && ./vendor/bin/sail run --rm laravel.test bash -c 'npm run development'
ci-setup-env:
	make $${LARAVEL_DIR}/.env

ci-test:
	cd ${LARAVEL_DIR} && \
		./vendor/bin/sail run --rm laravel.test bash -c 'php artisan test'

maintenance-update-all:
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 composer update
	cd $${LARAVEL_DIR} && npx npm-check --update-all

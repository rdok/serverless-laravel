export UID=$(shell id -u)
export GID=$(shell id -g)
export LARAVEL_DIR=$(shell pwd)/laravel

start: ${LARAVEL_DIR}/.env ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail up -d && \
		./vendor/bin/sail npm install && \
		./vendor/bin/sail npm run watch-poll
	# Visit http://localhost

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

setup-env:
	make $${LARAVEL_DIR}/.env
${LARAVEL_DIR}/.env:
	cd ${LARAVEL_DIR} && cp .env.example .env
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 bash -c " \
	composer install && php artisan key:generate"

test: ${LARAVEL_DIR}/.env ${LARAVEL_DIR}/vendor/bin/sail
	cd ${LARAVEL_DIR} && \
		./vendor/bin/sail run laravel.test bash -c 'php artisan test --without-tty --no-interaction'

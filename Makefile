export UID=$(shell id -u)
export GID=$(shell id -g)
export LARAVEL_DIR=$(shell pwd)/laravel

start: ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail up -d && \
		./vendor/bin/sail npm install && \
		./vendor/bin/sail npm run watch-poll
	# Visit http://localhost

down: ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail down

shell:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 bash

config-clear: ${LARAVEL_DIR}/vendor
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app \
		composer:2.0 bash -c 'php artisan config:clear'

deploy-laravel: config-clear npm-cleanup composer-prod
	CERTIFICATE_ARN=$$(aws cloudformation describe-stacks  \
		--region us-east-1 \
		--stack-name 'rdok-local-aws-sam-laravel-certificate' \
		--query 'Stacks[0].Outputs[?OutputKey==`CertificateARN`].OutputValue' \
		--output text) && \
	DB_VPC_ID=$$(aws ec2 describe-vpcs \
		--filters Name=isDefault,Values=true \
		--query 'Vpcs[*].VpcId' \
		--output text) && \
	DB_SUBNET_IDS=$$(aws ec2 describe-subnets \
		--filters Name=vpc-id,Values=$$DB_VPC_ID \
		--query 'Subnets[*].SubnetId' \
		--output text) && \
	DB_SUBNET_IDS=$$(echo $$DB_SUBNET_IDS | sed 's/ /,/g') && \
	DB_SECURITY_GROUP_ID=$$(aws ec2 describe-security-groups \
		--filter Name=group-name,Values=default \
		--query 'SecurityGroups[*].GroupId' \
		--output text) && \
	DB_SECRETS_ARN=$$(aws cloudformation describe-stacks  \
		--stack-name 'rdok-local-aws-sam-laravel-database' \
		--query 'Stacks[0].Outputs[?OutputKey==`SecretsARN`].OutputValue' \
		--output text) && \
	DB_HOST=$$(aws cloudformation describe-stacks  \
	   --stack-name 'rdok-local-aws-sam-laravel-database' \
	   --query 'Stacks[0].Outputs[?OutputKey==`DBHost`].OutputValue' \
	   --output text) && \
	sam deploy --parameter-overrides \
		DbVpcId=$$DB_VPC_ID \
		DbSubnetIds=$$DB_SUBNET_IDS \
		DbSecurityGroupId=$$DB_SECURITY_GROUP_ID \
		CertificateARN=$$CERTIFICATE_ARN \
		DbHost=$$DB_HOST \
		DbSecretsARN=$$DB_SECRETS_ARN \
		DomainName="aws-sam-laravel-local.rdok.co.uk" \
		WildcardCertificateARN='arn:aws:acm:us-east-1:353196159109:certificate/b7e23fbf-69a3-440f-8560-59f240f2cc09' \
		Route53HostedZoneId="ZSY7GT2NEDPN0"

deploy-assets:
	ASSETS_BUCKET=$$(aws cloudformation describe-stacks  \
		--stack-name 'rdok-local-aws-sam-laravel' \
		--query 'Stacks[0].Outputs[?OutputKey==`AssetsBucketARN`].OutputValue' \
		--output text) \
	&& \
	cd $$LARAVEL_DIR && \
	aws s3 sync ./public s3://$${ASSETS_BUCKET}/assets --delete

deploy-certificate:
	sam deploy  --config-env certificate --template template-certificate.yml

npm-prod: ${LARAVEL_DIR}/vendor/bin/sail
	cd $${LARAVEL_DIR} && \
		./vendor/bin/sail npm install && \
		./vendor/bin/sail npm run prod
	make npm-cleanup

${LARAVEL_DIR}/vendor/bin/sail:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

npm-cleanup:
	cd $${LARAVEL_DIR} && rm -rf node_modules

composer-prod:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 bash -c " \
		composer install --optimize-autoloader --no-dev && \
		php artisan route:cache && \
		php artisan view:cache \
	"
	# NOTE: config:cache is skipped due deployment breaking views path finding.

deploy-database:
	sam deploy --config-env database --template template-aurora.yml

${LARAVEL_DIR}/vendor:
	docker run -it -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

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
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app \
		composer:2.0 bash -c 'php artisan config:clear'

deploy-laravel: config-clear npm-cleanup composer-prod
	CERTIFICATE_ARN=$$(aws cloudformation describe-stacks  \
		--region us-east-1 \
		--stack-name 'rdokos-local-serverless-laravel-certificate' \
		--query 'Stacks[0].Outputs[?OutputKey==`CertificateARN`].OutputValue' \
		--output text) && \
	VPC_ID=$$(aws ec2 describe-vpcs \
		--filters Name=isDefault,Values=true \
		--query 'Vpcs[*].VpcId' \
		--output text) && \
	SUBNET_IDS=$$(aws ec2 describe-subnets \
		--filters "Name=vpc-id,Values=$${VPC_ID}" \
		--query 'Subnets[*].SubnetId' \
		--output text) && \
	SUBNET_IDS=$$(echo $$SUBNET_IDS | sed 's/ /,/g') && \
	sam deploy --parameter-overrides \
		CertificateARN=$$CERTIFICATE_ARN \
		DomainName="serverless-laravel-local.rdok.co.uk" \
		WildcardCertificateARN='arn:aws:acm:us-east-1:353196159109:certificate/b7e23fbf-69a3-440f-8560-59f240f2cc09' \
		AppKey='base64:offaTbmby+jJq+JxZlfMtjMb7BjyoNIGSj7bu49p6Zw=' \
		BaseDomainRoute53HostedZoneId="ZSY7GT2NEDPN0" \
		VpcId=$${VPC_ID} \
		AuroraStackName='rdokos-local-serverless-laravel-aurora' \
		SubnetIds=$${SUBNET_IDS}
	make deploy-storage-showcase

deploy-storage-showcase:
	STORAGE_BUCKET=$$(aws cloudformation describe-stacks \
		--region eu-west-1 \
		--stack-name 'rdokos-local-serverless-laravel' \
		--query 'Stacks[0].Outputs[?OutputKey==`StorageBucketName`].OutputValue' \
		--output text) && \
	aws s3 cp $$LARAVEL_DIR/storage/app/showcase-storage-retrieval.jpg s3://$${STORAGE_BUCKET}

deploy-assets:
	ASSETS_BUCKET_NAME=$$(aws cloudformation describe-stacks  \
		--stack-name 'rdokos-local-serverless-laravel' \
		--query 'Stacks[0].Outputs[?OutputKey==`AssetsBucketName`].OutputValue' \
		--output text) && \
	cd $$LARAVEL_DIR && \
	aws s3 sync ./public s3://$${ASSETS_BUCKET_NAME}/assets --delete

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
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app  composer:2.0 bash -c " \
		composer install --optimize-autoloader --no-dev && \
		php artisan view:cache"
	# NOTE: config:cache is skipped due deployment breaking views path finding.
# 		php artisan route:cache && \

deploy-aurora:
	VPC_ID=$$(aws ec2 describe-vpcs \
		--filters Name=isDefault,Values=true \
		--query 'Vpcs[*].VpcId' \
		--output text) && \
	sam deploy \
		--config-env database \
		--template template-aurora.yaml \
		--parameter-overrides \
			VpcId=$${VPC_ID}

vendor:
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

${LARAVEL_DIR}/vendor:
	docker run -u $${UID}:$${GID} -v "${LARAVEL_DIR}":/app composer:2.0 install

artisan: # command=inspire
	LAMBDA_NAME=$$(aws cloudformation describe-stacks  \
		--region eu-west-1 \
		--stack-name 'rdokos-local-serverless-laravel' \
		--query 'Stacks[0].Outputs[?OutputKey==`ArtisanLambdaName`].OutputValue' \
		--output text) && \
	aws lambda invoke \
	    --region eu-west-1 \
		--cli-binary-format raw-in-base64-out \
		--function-name "$${LAMBDA_NAME}" \
		--payload '"$(command)"' \
			response.json && \
	cat response.json
	rm response.json

# 	LARAVEL_SECURITY_GROUP_ID=$$(aws cloudformation describe-stacks  \
# 		--stack-name 'rdokos-local-serverless-laravel' \
# 		--query 'Stacks[0].Outputs[?OutputKey==`LaravelSecurityGroupId`].OutputValue' \
# 		--output text) && \

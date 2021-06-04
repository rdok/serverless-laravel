#  serverless Laravel
> A production ready implementation of [The serverless LAMP stack part 4: Building a serverless Laravel application](https://aws.amazon.com/blogs/compute/the-serverless-lamp-stack-part-4-building-a-serverless-laravel-application/). Includes CI/CD using [GitHub Actions][ci_cd].
 
[![CI/CD prod][cd_prod_badge]][cd_prod]
[![test-site][test_site_badge]][test_site]
[![prod-site][prod_site_badge]][prod_site]

Simply clone, add AWS Credentials, update stackname and deploy `test` & `prod` environments using GitHub actions.

STORY_LINK_HERE documents the highlights. 

#### AWS resource requirements
An existing base domain & wild card certificate.

## Infrastructure
![alt text][infrastructure]

### Develop
`make start` to start local development. See `Makefile` for more.

[bref]: https://bref.sh/
[ci_cd]: https://github.com/rdok/serverless-laravel/actions
[cd_prod_badge]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml/badge.svg?event=workflow_dispatch
[cd_prod]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml
[prod_site_badge]: https://img.shields.io/badge/prod-blue?style=flat-square&logo=amazon-aws
[prod_site]: https://serverless-laravel-local.rdok.co.uk/
[test_site_badge]: https://img.shields.io/badge/Test-green?style=flat-square&logo=amazon-aws
[test_site]: https://serverless-laravel-test.rdok.co.uk/
[infrastructure]: ./infrastructure.webp

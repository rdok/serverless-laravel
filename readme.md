#  serverless Laravel
> Learn how to set this up at https://stories.rdok.co.uk/2021/06/serverless-laravel/

[![CI/CD prod][cd_prod_badge]][cd_prod]
[![test-site][test_site_badge]][test_site]
[![prod-site][prod_site_badge]][prod_site]

## Infrastructure
![alt text][infrastructure]

### Develop
`make` to start local development. See `Makefile` for more.
- `make start-sam` to run laravel through AWS SAM lambda. Use this to verifying bref integration mainly; else rely on `make` which is a more efficient workflow.

[bref]: https://bref.sh/
[ci_cd]: https://github.com/rdok/serverless-laravel/actions
[cd_prod_badge]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml/badge.svg?event=workflow_dispatch
[cd_prod]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml
[prod_site_badge]: https://img.shields.io/badge/Prod-blue?style=flat-square&logo=amazon-aws
[prod_site]: https://serverless-laravel.rdok.co.uk/
[test_site_badge]: https://img.shields.io/badge/Test-green?style=flat-square&logo=amazon-aws
[test_site]: https://serverless-laravel-test.rdok.co.uk/
[infrastructure]: ./laravel/public/img/infrastructure.jpg

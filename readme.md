#  serverless Laravel
> A production ready implementation.
 
[![CI/CD prod][cd_prod_badge]][cd_prod]
[![prod-site][prod_site_badge]][prod_site]

This is a ready for production, implementation of [The serverless LAMP stack part 4: Building a serverless Laravel application](https://aws.amazon.com/blogs/compute/the-serverless-lamp-stack-part-4-building-a-serverless-laravel-application/) Includes CI/CD using [GitHub Actions][ci_cd].

Simply clone, add AWS Credentials and deploy away using GitHub actions.


### Requirements
An existing domain & wild card certificate. STORY_LINK_HERE documents their need.

### Develop
`make`

## Infrastructure
![alt text][infrastructure]


[bref]: https://bref.sh/
[ci_cd]: https://github.com/rdok/serverless-laravel/actions
[cd_prod_badge]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml/badge.svg?event=workflow_dispatch
[cd_prod]: https://github.com/rdok/serverless-laravel/actions/workflows/deploy.yml
[prod_site_badge]: https://img.shields.io/badge/prod-grey?style=flat-square&logo=heroku
[prod_site]: https://serverless-laravel-local.rdok.co.uk/
[infrastructure]: ./infrastructure.png

# aws-sam-laravel
[![CI/CD prod][cd_prod_badge]][cd_prod]
[![prod-site][prod_site_badge]][prod_site]


Minimalist Laravel using AWS SAM & [bref][bref]. 

Includes CI/CD using [GitHub Actions][ci_cd].

![alt text][design]

#### Run locally
`make start`

#### Deploy locally
`sam deploy --guided`

[bref]: https://bref.sh/
[ci_cd]: https://github.com/rdok/aws-sam-laravel/actions
[cd_prod_badge]: https://github.com/rdok/aws-sam-laravel/actions/workflows/deploy.yml/badge.svg?event=workflow_dispatch
[cd_prod]: https://github.com/rdok/aws-sam-laravel/actions/workflows/deploy.yml
[prod_site_badge]: https://img.shields.io/badge/prod-grey?style=flat-square&logo=heroku
[prod_site]: https://dzbqyvm7dn9up.cloudfront.net/
[design]: ./readme-design.png

# Portfolio backend
[![Actions Status](https://github.com/Vadlusk/portfolio_backend/workflows/CI/badge.svg)](https://github.com/Vadlusk/portfolio_backend/actions)
[![Coverage Status](https://coveralls.io/repos/github/Vadlusk/portfolio_backend/badge.svg?branch=main)](https://coveralls.io/github/Vadlusk/portfolio_backend?branch=main) [![Maintainability](https://api.codeclimate.com/v1/badges/1f8a15b270dfe3a26b0c/maintainability)](https://codeclimate.com/github/Vadlusk/portfolio_backend/maintainability)

A simple Rails api with 3 endpoints (signing up, in, and deleting an account).  
Written so that only happy path code goes into controllers.

## Setup

1. `git clone https://github.com/Vadlusk/portfolio.git <your_desired_project_name>`
1. [Set up Code Climate](https://codeclimate.com/dashboard)
1. [Set up Coveralls](https://coveralls.io/) - turn the project on, click on details, copy the `repo_token` and paste into `./.coveralls.yml`.

1. `bundle exec rake db:create db:migrate db:test:prepare`
1. Run tests with `bundle exec rspec`.

## Endpoints

`POST api/v1/users` & `POST api/v1/users/authenticate`

Both work the same way. The only difference is that the former is used for new users and the latter for existing. These two are intended to be the only client_id protected endpoints, unless you'd like to add another endpoint for exchanging refresh tokens for access tokens (and also implement those types of tokens). To use, send:

```
params  = { email: email, password: password }  
headers = { "Authorization": "Token token=<client_id>" }
```

You will receive a 200 or 204 respectively and a user_id and token. The JWT that is returned in the token key must be sent back on subsequent requests to access the rest of the API.

`DELETE api/v1/users/:id`

An example of a JWT protected endpoint. To use this and any other endpoint a valid JWT must be sent in the following format as a request header:

```
{ "Authorization": "Basic token=<JWT>" }
```

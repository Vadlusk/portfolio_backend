# Rails JWT Authentication Boilerplate [![Coverage Status](https://coveralls.io/repos/github/Vadlusk/JWT_boilerplate/badge.svg?branch=master)](https://coveralls.io/github/Vadlusk/JWT_boilerplate?branch=master) [![CircleCI](https://circleci.com/gh/Vadlusk/JWT_boilerplate.svg?style=shield)](https://circleci.com/gh/Vadlusk/JWT_boilerplate) [![Maintainability](https://api.codeclimate.com/v1/badges/1f8a15b270dfe3a26b0c/maintainability)](https://codeclimate.com/github/Vadlusk/JWT_boilerplate/maintainability)

A simple Rails api with 3 endpoints (signing up, in, and deleting an account).  
Written so that only happy path code goes into controllers.

## Setup

1. `git clone https://github.com/Vadlusk/JWT_boilerplate.git <your_desired_project_name>`
1. [Change the name of the project.](https://stackoverflow.com/questions/42326432/how-to-rename-a-rails-5-application)
1. [Setup CI](https://circleci.com/) - repo already has configuration for CircleCI.
1. [Setup Coveralls](https://coveralls.io/) - turn the project on, click on details, copy the `repo_token` into `./.coveralls.yml`.
1. [Setup Code Climate](https://codeclimate.com/dashboard)
1. Change `JWT_boilerplate` in the top of this README to `<your_desired_project_name>` if you haven't already in step 2.
1. `bundle install`
1. `bundle exec figaro install`
1. Open `config/application.yml` and add 3 ENV variables:  
    `client_id`: a string your client apps will need to know to get authentication access  
    `jwt_string`: a string used to encrypt your JWTs against  
    `jwt_encryption_algorithm`: [pick one from the list here](https://github.com/jwt/ruby-jwt#algorithms-and-usage) and include it as a string
1. `bundle exec rake db:create db:migrate db:test:prepare`
1. Run tests with `bundle exec rspec`.

## Endpoints

Both `POST api/v1/users` and `POST api/v1/users/authenticate` work the same way. The only difference is that the former is used for new users and the latter for existing. These two are intended to be the only client_id protected endpoints, unless you'd like to add another endpoint for exchanging refresh tokens for access tokens (and also implement those types of tokens). To use, send:

```
params  = { email: email, password: password }  
headers = { "Authorization": "Token token=<client_id>" }
```

You will receive a 200 or 204 and a user_id and token. The JWT that is returned in the token key must be sent back on subsequent requests to access the rest of the API.

`DELETE api/v1/users/:id` is an example of a JWT protected endpoint. To use this and any other endpoint a valid JWT must be sent in the following format as a request header:

```
{ "Authorization": "Basic token=<JWT>" }
```

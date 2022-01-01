
# Crypto Portfolio Tracker (backend)
[![Actions Status](https://github.com/Vadlusk/portfolio_backend/workflows/CI/badge.svg)](https://github.com/Vadlusk/portfolio_backend/actions)
[![Coverage Status](https://coveralls.io/repos/github/Vadlusk/portfolio_backend/badge.svg)](https://coveralls.io/github/Vadlusk/portfolio_backend) [![Maintainability](https://api.codeclimate.com/v1/badges/d1b01615db93fc0c5288/maintainability)](https://codeclimate.com/github/Vadlusk/portfolio_backend/maintainability)

Rails app with postgresql db for Crypto Portfolio Tracker

## Setup

1. `git clone https://github.com/Vadlusk/portfolio_backend.git <your_desired_project_name>`
1. `cd <your_desired_project_name>`
1. `bundle`
1. `bundle exec figaro install`
1. put the following in `config/application.yml`:
```
# app auth
client_id: <any_string_that_matches_corresponding_variable_in_front_end>
jwt_string: <any_random_string>
jwt_encryption_algorithm: <valid_algorithm>
# third party auth
celcius_wallet_api_key: <request a partner key from partners@celsius.network>
```
[(list of valid algorithms found here)](https://datatracker.ietf.org/doc/html/rfc7518#section-3.1)
1. `bundle exec rake db:create db:migrate db:test:prepare`
1. Run tests with `bundle exec rspec`.

`bundle exec` may or may not be necessary.
## Endpoints

The first group of endpoints requires the following:

params = `{ email: <email>, password: <password> }`  
headers = `{ "Authorization": "Token token=<client_id>" }`

`POST api/v1/users`

creates a user

`POST api/v1/users/authenticate`

authenticates a returning user

The last group requires a valid JWT in the headers
`{ "Authorization": "Basic token=<JWT>" }`

`DELETE api/v1/users/:id`

deletes the user and all associated records

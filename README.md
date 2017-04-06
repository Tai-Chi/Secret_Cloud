# Secret_Cloud
API to store and retrieve user data

## To run the server:

1. $ bundle install
2. $ rackup
3. in your browser 'localhost:[portnumber]/'
4. use the following routes

## Routes

- get `api/v1/configurations/`: returns a json of all user IDs
- get `api/v1/configurations/[ID].json`: returns a json of all information with the given user ID
- post `api/v1/configurations/` : store user data. Request body must be a json, which must contain all data of the user

# using env to load the applicable .env file
# This is a workaround for docker-compose as it doesn't allow --env-file option
# 
# Example use:   ./docker-compose-run.sh .env.example

# $1 is the .env file name passed to this script as a command line parameter
env $(cat $1) docker-compose run --rm plantuml-client
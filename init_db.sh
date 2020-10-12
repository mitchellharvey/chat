#!/usr/bin/bash

# Default values for docker images
DB_CONTAINER_NAME=dggchat_mysql_1

# The username and password that chat service will use to login. These should match the ones in
# settings.cfg
DGG_USER=dgguser
DGG_PASSWORD=dggpassword
DGG_DATABASE=destinygg

# ROOT Database password defined in the docker-compose.yml
DB_ROOT_PASSWORD=dbpassword


# Gather ROOT password from sql logs
# echo "Retrieve root db password from container ..."
#DB_ROOT_PASSWORD=$(docker logs $DB_CONTAINER_NAME 2> /dev/null | grep "GENERATED ROOT PASSWORD" | cut -d':' -f2 | xargs)

#if [ -z "$DB_ROOT_PASSWORD" ]
#then
    #echo "Unable to get MySQL Root Password, is the container [$DB_CONTAINER_NAME] running?"
    #exit 1
#fi

#echo "Got root: $DB_ROOT_PASSWORD"

# Create inital destinygg user/password in Database

CREATE_USERS="""
CREATE USER IF NOT EXISTS '$DGG_USER'@'%' IDENTIFIED BY '$DGG_PASSWORD';
DROP DATABASE IF EXISTS $DGG_DATABASE;
CREATE DATABASE $DGG_DATABASE;
GRANT ALL PRIVILEGES ON $DGG_DATABASE.* TO '$DGG_USER'@'%';
SET GLOBAL sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
"""

echo "Create initial credentials for dbuser [$DGG_USER] on database [$DGG_DATABASE]"
docker exec -it $DB_CONTAINER_NAME mysql --user=root --password=$DB_ROOT_PASSWORD -e "$CREATE_USERS"

echo "Create [$DGG_DATABASE] schema ..."

# Download latest schema from dggwebsite repository
SCHEMA=$(curl -L https://github.com/destinygg/website/raw/master/config/destiny.gg.sql --silent)
FINAL_SCHEMA="""
USE $DGG_DATABASE;
$SCHEMA
"""

docker exec -it $DB_CONTAINER_NAME mysql --user=$DGG_USER --password=$DGG_PASSWORD -e "$FINAL_SCHEMA"

echo "DONE!"


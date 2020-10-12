#!/usr/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# SQL Client by default just use the one in the container that has local access to the DB
SQL_CLIENT="docker exec -it dggchat_mysql_1 mysql"

# The username and password that chat service will use to login. These should match the ones in
# docker-compose.yml
DGG_USER=dgguser
DGG_PASSWORD=dggpassword
DGG_DATABASE=destinygg
DOCKER_DB_VOLUME=.database

# Change ownership of database volume to current user.  This is obnoxious but docker and docker-compose don't expose
# a dynamic way to set ownership on volumes cleanly
user=$(id -u):$(id -g)
sudo chown -R $user "$SCRIPT_DIR"/../$DOCKER_DB_VOLUME

# Create manual database setup and combine with downloaded schema file to initialize our database
DOWNLOADED_SCHEMA=$(curl -L https://github.com/destinygg/website/raw/master/config/destiny.gg.sql --silent)
CREATE_DB="""
USE $DGG_DATABASE;
$DOWNLOADED_SCHEMA
"""

$SQL_CLIENT --user=$DGG_USER --password=$DGG_PASSWORD -e "$CREATE_DB"


echo "DONE!"



The Destiny Chat Back-End
===========

The chat back-end for destiny.gg, written in Go, based on Golem (http://github.com/trevex/golem) 

Licensed under the Apache License, Version 2.0 

http://www.apache.org/licenses/LICENSE-2.0.html

This is my (sztanpet's) first not-so-tiny Go project, so if there is anything that could be improved, please do tell.

### How to Build & Run

1. Clone this repo.

```
$ git clone https://github.com/destinygg/chat.git
```

2. Navigate into the project folder.

```
$ cd chat
```

3. Download all dependencies.

```
$ go mod download
```

4. Verify dependency checksums to ensure nothing fishy is going on.

```
$ go mod verify
```

5. Build the binary.

```
$ go build -o chat
```

6. Run the binary.

```
$ ./chat
```

If a `settings.cfg` file doesn't exist, one will be created on first run. Modify it to your liking and run the binary again when done.


### Using Docker Compose

Ensure you have installed and are able to run `docker-compose` from the command line.

https://docs.docker.com/compose/install/


#### Initial Setup / Build
Just change directory into the main repository directory and run the command:

```
docker-compose up -d
```

This will do any container building neccesary and start the containers in a detached (`-d`) state.

**Setup Database**

Initially after a docker-compose build the MySQL and Redis databases will be cleared, meaning you'll need to reinitailize MySQL with the correct database, user and schema

There is a script provided that will download the latest schema file from the dggwebsite source code and setup a new database using that schema.

```
./init_db.sh
```

If you aren't using the default connection information set in the `docker-compose.yml` file for the root database password, or those setup in `main.go` for the default settings.cfg then you may want to edit this script with your values.

**WARNING:** If you run this script again, it will always wipe and recreate the database, you should only need to do this once unless you specifically want to wipe your database


**Turn off containers**

If you don't want your docker containers constantly running, you can always bring them down as a group with the following command run from the project root directory.

```
docker-compose down
```

Your database will persist between containers starts and shutdowns but if you rebuild then you will have to reinitailize the database.

#### Monitoring Services

If you want to view the logs for all or any particular service you can run:

**Tail logs of all services**

```
docker-compose logs -f
```

**Tail logs just the chat service**

```
docker-compose logs -f chat
```

**Execute command on a container**
Sometimes you may want to execute a command on a container, like running the mysql client to connect to the db.

The following command will launch the mysql client within the context of the mysql container (the full container name created by docker-compose) as the root user prompted for password.

```
docker exec -it dggchat_mysql_1 mysql -u root -p
```

Sometimes for debugging purposes you may want to pop a shell in a container to see what the filesystem looks like relative to the container (does it see my new files?, ect.)

```
docker exec -it dggchat_chat_1 /bin/bash
```

#### Rebuilding Chat Code

When you've made and changes to the golang code, if you just restart the chat service it will attempt to build the new client before starting it again.

```
docker-compose restart chat
```


Forked from [ktwe](https://github.com/ktwe/docker-bareos-director)

For more information visit the Github repositories:
* [bareos-director](https://github.com/ssd-adventist/docker-bareos-director)
* [bareos-webui](https://github.com/ssd-adventist/docker-bareos-webui)
* [bareos-storage](https://github.com/ssd-adventist/docker-bareos-storage)

# About
This package provides images for [Bareos](http://www.bareos.org) Diretor, WebUI and Storage Daemon. It's based on Ubuntu Trusty and the Bareos package repository. PostgreSQL is required as catalog backend. Every component runs in an single container and is linked together.

# Security advice
The default passwords inside the configuration files are created when building the docker image. So for production either build the image yourself using the sources from Github or change all the passwords manually. 

# Set up
## PostgreqSQL
Simply use the official postgres image. Just replace `<PASSWORD>` a strong database password and `<db_path>` if you like to store the database in a volume.

```
docker run --name bareos-db \
-e POSTGRES_PASSWORD=<PASSWORD> \
-v <db_path>:/var/lib/postgresql/data \
-d postgres:9.4
```

**Important:** Do not use the database container for anything else as the database password gets exposed to the Bareos container.

## Bareos Director
This image runs latest Bareos version 15.2. Replace `<PASSWORD>` with a strong password for the bareos database. We also recommend to store the bareos config to an external volume for easy editing. To do so set `<etc_path>`.

If you changed the name of your database container, change the `--link` parameter as well.

```
docker run --name bareos-director \
-e BAREOS_DB_PASSWORD=<PASSWORD> \
-v <etc_path>:/etc/bareos \
--link bareos-db:db \
-p 9101:9101 \
-d ssdit/bareos-director:latest
```

**Some notes:** The bareos config file has been modified so any _.conf_ file inside `/etc/bareos/bareos-dir.d/` is included.

## Bareos WebUI
We also recommend to store the bareos config to an external volume for easy editing. To do so set `<etc_path>`. If you changed the name of your director container, change the `--link` parameter as well.

```
docker run --name bareos-webui \
-v <etc_path>:/etc/bareos-webui \
--link bareos-director:director \
-p 8080:80 \
-d ssdit/bareos-webui:latest
```

To enable login from the WebUI to the director, simply copy the default config files out of the container to your external director config volume:

```
docker cp bareos-webui:/etc/bareos/bareos-dir.d/webui-consoles.conf webui-consoles.conf
docker cp bareos-webui:/etc/bareos/bareos-dir.d/webui-profiles.conf webui-profiles.conf
docker cp webui-consoles.conf bareos-director:/etc/bareos/bareos-dir.d/webui-consoles.conf
docker cp webui-profiles.conf bareos-director:/etc/bareos/bareos-dir.d/webui-profiles.conf
rm webui-consoles.conf webui-profiles.conf
```

## Bareos Storage Daemon
**Note:** Because the Storage Daemon needs access to tape devices and/or hard drives, it's not recommended to run it inside a docker container.

We recommend to store the bareos config to an external volume for easy editing. To do so set `<etc_path>`. `storage path` points to the default folder for the backup volumes and should have a large amount of space.

```
docker run --name bareos-storage \
-v <etc_path>:/etc/bareos \
-v <storage_path>:/var/lib/bareos/storage \
-p 9103:9103
-d ssdit/bareos-storage:latest
```

Next allow the director to access the storage daemon. Get the password of the storage daemon:
```
docker exec -it bareos-storage grep -i -m 1 "Password = " /etc/bareos/bareos-sd.conf | awk '{ print $3 }'
```

Now edit `bareos-dir.conf` of your director container and replace the password inside the *Storage* directive with the one of your storage daemon. The address inside the directive must be set to the docker host, where the storage daemon is reachable, e.g.:

```
Storage {
  Name = File
  Address = 192.168.1.1
  Password = "1234"
  Device = FileStorage
  Media Type = File
}
```

# Usage
## WebUI
Open http://your-host:8080/bareos-webui in your browser. Default username and password is user1/CHANGEME (see webui-consoles.conf).

## bconsole
Run `docker exec -it bareos-director bconsole`.

For more information visit the Github repositories:
* [bareos-director](https://github.com/ktwe/docker-bareos-director)
* [bareos-webui](https://github.com/ktwe/docker-bareos-webui)

# About
This package provides images for [Bareos](http://www.bareos.org) Diretor and WebUI. It's based on Ubuntu trusty and the Bareos package repository. PostgreSQL is required as catalog backend. Every component runs in an single container and is linked together.

# Set up
## PostgreqSQL
Simply use the official postgres image. Just replace `<PASSWORD>` a strong database password and `<db_path>` if you like to store the database in a volume.

```
docker run --name bareos-db \
-e POSTGRES_PASSWORD=<PASSWORD> \
-v <db_path>:/var/lib/postgresql/data \
-d postgres
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
-d ktwe/bareos-director:15.2
```

**Some notes:** The bareos config file has been modified so any _.conf_ file inside `/etc/bareos/bareos-dir.d/` is included.

## Bareos WebUI
We also recommend to store the bareos config to an external volume for easy editing. To do so set `<etc_path>`. If you changed the name of your director container, change the `--link` parameter as well.

```
docker run --name bareos-webui \
-v <etc_path>:/etc/bareos-webui \
--link bareos-director:director \
-p 8080:80 \
-d ktwe/bareos-webui:15.2
```

To enable login from the WebUI to the director, simply copy the default config files out of the container to your external director config volume:

```
docker cp bareos-webui:/etc/bareos/bareos-dir.d/webui-consoles.conf /your/director/config/bareos-dir.d/
docker cp bareos-webui:/etc/bareos/bareos-dir.d/webui-profiles.conf /your/director/config/bareos-dir.d/
```
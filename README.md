# OpenTSDB in Docker

This is Google Cloud BigTable ready OpenTSDB server docker image. Tags are corresponding
to OpenTSDB releases.

## Configuration

Containers from this image are fully configured with environment variables.
To convert OpenTSDB configuration property name to env variable name,
you should:

1. Add prefix `TSD_CONF_`
2. Replace `.` with `__`

You can also make variable name upper case. An example:

* `tsd.network.async_io` becomes `TSD_CONF_tsd__network__async_io`

To see available configuration properties, take a look at config
[options](http://opentsdb.net/docs/build/html/user_guide/configuration.html).

## JVM options

OpenTSDB sets `JVMARGS=""-enableassertions -enablesystemassertions"`. You
can change this env variable to tune JVM. It's a good idea to set heap
size limit with `-Xmx` option:

```
JVMARGS="-Xms2g -Xmx2g -enableassertions -enablesystemassertions"
```

## Cache cleanup

OpenTSDB does not support automatic cache cleanup, but cache directory
can become quite big for intense users. To fix this problem, this image
removes old cache entries from cache directory. There are two environment
variables that control cleanup process:

* `TSD_CACHE_CLEANUP_INTERVAL` interval between cleanups in seconds
* `TSD_CACHE_MAX_AGE_MINUTES` max age of cache files in minutes


## Log level

The following log level env variables exist:

* `TSD_ROOT_LOG_LEVEL` to set root log level, defaults to `INFO`.
* `TSD_QUERY_LOG_LEVEL` to set query log level, defaults to `INFO`.

Note that default root log level is quite verbose and you'll probably want
to change it to `WARN` for production. Setting query log level to `WARN`
or higher effectively disables query logging.

## Running ad-hoc OpenTSDB commands

If you supply any args to the image, they will be passed to `tsdb` executable.
This way you could run `fsck`:

```bash
docker run [...] deeone/opentsdb-bigtable:2.3.0.0 fsck --full-scan --fix-all --compact
```

Creating and importin metrics:

```bash
docker run --rm -it \
-e TSD_CONF_google__bigtable__project__id=${PROJECT_ID} \
-e TSD_CONF_google__bigtable__instance__id=${INSTANCE_ID} \
-e TSD_CONF_google__bigtable__zone__id=${ZONE_ID} \
-e TSD_CONF_hbase__client__connection__impl=com.google.cloud.bigtable.hbase1_2.BigtableConnection \
-v ~/.config/gcloud:/home/opentsdb/.config/gcloud -v /data:/data \
 deeone/opentsdb-bigtable:2.3.0 mkmetric NYSE_A NYSE_B NYSE_C NYSE_D NYSE_E NYSE_F NYSE_G NYSE_H

docker run --rm -it \
-e TSD_CONF_google__bigtable__project__id=${PROJECT_ID} \
-e TSD_CONF_google__bigtable__instance__id=${INSTANCE_ID} \
-e TSD_CONF_google__bigtable__zone__id=${ZONE_ID} \
-e TSD_CONF_hbase__client__connection__impl=com.google.cloud.bigtable.hbase1_2.BigtableConnection \
-v ~/.config/gcloud:/home/opentsdb/.config/gcloud -v /data:/data \
 deeone/opentsdb-bigtable:2.3.0 import /data/A.txt /data/B.txt /data/C.txt /data/D.txt /data/E.txt /data/F.txt /data/G.txt /data/H.txt
```

Config is is still picked up from environment in this case.

## Security

After initial configuration container drops root privileges and runs
with dedicated `opentsdb` user.


### Creating tables using cbt

```bash
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createtable tsdb 
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createtable tsdb-uid
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createtable tsdb-meta
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createtable tsdb-tree
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createfamily tsdb t   
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createfamily tsdb-tree t
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createfamily tsdb-meta t
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createfamily tsdb-uid id
cbt -instance ${INSTANCE_ID} -project ${PROJECT_ID} createfamily tsdb-uid name
```

### Running

```bash
docker run --rm -it \
-e TSD_CONF_tsd__network__port=4242 \
-e TSD_CONF_tsd__network__bind=0.0.0.0 \
-e TSD_CONF_google__bigtable__project__id=${PROJECT_ID} \
-e TSD_CONF_google__bigtable__instance__id=${INSTANCE_ID} \
-e TSD_CONF_google__bigtable__zone__id=${ZONE_ID} \
-e TSD_CONF_hbase__client__connection__impl=com.google.cloud.bigtable.hbase1_2.BigtableConnection \
-p 4242:4242 \
-v ~/.config/gcloud:/home/opentsdb/.config/gcloud \
 deeone/opentsdb-bigtable:2.3.0 
``` 

## License

[MIT](LICENSE)

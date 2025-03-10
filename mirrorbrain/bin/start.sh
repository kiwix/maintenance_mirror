#!/bin/sh
if [ ! -z $INIT ]
then
  init_mirrorbrain_db.sh
fi

if [ ! -z $UPDATE_DB ]
then
  echo "Install Cron to update DB"
  { \
    echo "#!/bin/sh" ; \
    echo "/usr/bin/flock -w 0 /dev/shm/cron.lock /usr/local/bin/update_mirrorbrain_db.sh >>/dev/shm/update_mb.log 2>&1" ; \
  } > /etc/cron.hourly/update_mirrorbrain_db && chmod 0500 /etc/cron.hourly/update_mirrorbrain_db
  { \
    echo "#!/bin/sh" ; \
    echo "mb mirrorlist -f xhtml | grep -v "href=\"\"" > /var/www/download.kiwix.org/mirrors.html" ; \
  } > /etc/cron.daily/update_mirrorlist && chmod 0500 /etc/cron.daily/update_mirrorlist
  { \
    echo "#!/bin/sh" ; \
    echo "find /var/www/download.kiwix.org/nightly/ -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;" ; \
    echo "find /var/www/download.openzim.org/nightly/ -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;" ; \
    echo "find /var/www/download.openzim.org/wp1/ -mindepth 1 -maxdepth 1 -type d -mtime +730 -exec rm -rf {} \;" ; \
    echo "find /data/tmp/ci/ -mindepth 1 -maxdepth 1 -mtime +30 -exec rm -rf {} \;" ; \
  } > /etc/cron.daily/remove_nightlies && chmod 0500 /etc/cron.daily/remove_nightlies
  { \
    echo "#!/bin/sh" ; \
    echo "* * * * * www-data /usr/bin/flock -w 0 /dev/shm/mirrorprobe.lock /usr/local/bin/mirrorprobe.sh >>/dev/null 2>&1" ; \
  } > /etc/cron.d/mirrorprobe && chmod 0500 /etc/cron.d/mirrorprobe
fi

if [ ! -z $UPDATE_HASH ]
then
  echo "Install Cron to update hash"
  { \
    echo "#!/bin/sh" ; \
    echo "/usr/bin/flock -w 0 /dev/shm/cron.lock /usr/local/bin/hash_mirrorbrain_db.sh >>/dev/shm/hash_mb.log 2>&1" ; \
  } > /etc/cron.hourly/hash_mirrorbrain_db && chmod 0500 /etc/cron.hourly/hash_mirrorbrain_db
fi

if [ ! -z $HTTPD ]
then
  service cron start
  echo "Start HTTPD ..."
  httpd-foreground
else
  if [ ! -z $UPDATE_HASH ] ||  [ ! -z $UPDATE_DB ]
  then
    echo "Start Cron ..."
    cron -f
  fi
fi

if [ ! -z $GEOIPUPDATE ]
then
  geoipupdate -v
fi

if [ ! -z $HTTPD_ONLY ]
then
  httpd-foreground
fi
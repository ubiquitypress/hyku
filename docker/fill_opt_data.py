#! /bin/python

# This script will check whether `/opt/data` is empty, and if it is, fill the
# directory with the content from the standard `/opt/solr/server/solr`. This
# operation must happen in a container where `/opt/data` is mounted from an
# external volume, in order for it to be preserved on a container restart.

from os import listdir
from subprocess import call


DEST_DIR = '/opt/solr/home'


if len(listdir(DEST_DIR)) <= 1:  # 'lost+found' folder might be in the dir.
    call(
        'cp -r /opt/solr/server/solr/* {dest}/.'.format(dest=DEST_DIR),
        shell=True
    )
    print('Copied original config folder to {d}'.format(d=DEST_DIR))
else:
    print('{d} is not empty, passing.'.format(d=DEST_DIR))

#!/bin/bash

TARGET_DIR=/var/www/download.kiwix.org/portable/
SCRIPT=/var/www/kiwix/tools/tools/scripts/buildDistributionFile.pl
SYNC_DIRS="zim/0.9 zim/other zim/wikipedia"
KIWIX_VERSION=`ls -la /var/www/download.kiwix.org/bin/unstable | cut -d " " -f10 | sed -e 's/_/-/g' | sed -e 's/\///g'` 

cd /var/www/kiwix/tools/scripts

for DIR in $SYNC_DIRS
do
    for FILE in `rsync -az download.kiwix.org::download.kiwix.org/$DIR/ | sed -e 's/^.* //g' | grep '\....' | grep zim`
    do
	FILENAME="kiwix-"$KIWIX_VERSION+`echo $FILE| sed -e 's/zim/zip/g'`
	if [ ! -f "$TARGET_DIR"/"$FILENAME" ]
	then
	    echo "Building $FILENAME..."
	    cd `dirname "$SCRIPT"`
	    $SCRIPT --filePath="/tmp/$FILENAME" --zimPath="/var/www/download.kiwix.org/$DIR/$FILE" --type=portable

	    echo "Move to $TARGET_DIR"
	    mv "/tmp/$FILENAME" "$TARGET_DIR/"
	else
	    echo "Skipping $FILENAME..."
	fi
    done
done
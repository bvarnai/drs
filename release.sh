#!/bin/bash -e

mkdir -p build/drs build/release

pushd build

# start from scratch
rm -r drs/ release/
mkdir drs/ release/

# stage sources
cp ../src/* drs/

# release archive
tar -zcvf drs.tar.gz drs/

# checksum
sha256sum drs.tar.gz >> drs.tar.gz.sha256
mv drs.tar.gz drs.tar.gz.sha256 release/

popd

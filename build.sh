#!/usr/bin/env bash
set -e

PROJECT=$HOME/github/alexpreynolds
STAMP='default'
SERVER_VERSION='1.6.0'
WEBSITE_VERSION='0.6.21'
# LIBRARY_VERSION='0.10.19'

usage() {
  echo "USAGE: $0 -w WORKERS [-s STAMP] [-l]" >&2
  exit 1
}

while getopts 's:w:l' OPT; do
  case $OPT in
    s)
      STAMP=$OPTARG
      ;;
    w)
      WORKERS=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z $WORKERS ]; then
  usage
fi

set -o verbose # Keep this after the usage message to reduce clutter.

# When development settles down, consider going back to static Dockerfile.
perl -pne "s/<SERVER_VERSION>/$SERVER_VERSION/g; s/<WEBSITE_VERSION>/$WEBSITE_VERSION/g; s/<LIBRARY_VERSION>/$LIBRARY_VERSION/g" \
          web-context/Dockerfile.template > web-context/Dockerfile

if [ ! -f $PROJECT/higlass/dist/scripts/hglib.js ]
then
    echo "hglib.js not found -- compile per instructions"
fi
cp $PROJECT/higlass/dist/scripts/hglib.js web-context/higlass/dist/scripts/hglib.js

if [ ! -f $PROJECT/higlass/dist/styles/hglib.css ]
then
    echo "hglib.css not found -- compile per instructions"
fi
cp $PROJECT/higlass/dist/styles/hglib.css web-context/higlass/dist/styles/hglib.css

REPO=pkerpedjiev/accion
docker pull $REPO # Defaults to "latest", but just speeds up the build, so precise version doesn't matter.
docker build --cache-from $REPO \
             --build-arg WORKERS=$WORKERS \
             --tag hg-dev-image-$STAMP \
             web-context

#rm web-context/Dockerfile # Ephemeral: We want to prevent folks from editing it by mistake.


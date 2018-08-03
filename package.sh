#!/bin/sh

NAME=$(grep -E '^name:' META.yaml | awk '{ print $2 }')
VERSION=$(grep -E '^version:' META.yaml | awk '{ print $2 }')

mkdir -p .build/$NAME-$VERSION
cp -r * .build/$NAME-$VERSION
(
    cd .build
    tar -c -f $NAME-$VERSION.tar --owner=nobody --group=nobody $NAME-$VERSION
    gzip $NAME-$VERSION.tar
)

find .build -mindepth 1 -maxdepth 1 -type f -name "$NAME-$VERSION.*"

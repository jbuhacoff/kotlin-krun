#!/bin/bash

KRUN_CACHE=${KRUN_CACHE:-$HOME/.krun}

find_kotlin_runtime() {
    # sdkman
    if [ -f $HOME/.sdkman/candidates/kotlin/current/lib/kotlin-runtime.jar ]; then
        echo '$HOME/.sdkman/candidates/kotlin/current/lib/kotlin-runtime.jar'
        return 0
    fi

    # anywhere else
    found=$(find / -type f -name kotlin-runtime.jar 2>/dev/null | head -n 1 | tr ' ' ':')
    if [ -n "$found" ]; then
        echo "$found"
        return 0
    fi

    echo "cannot find kotlin-runtime.jar" >&2
    return 1
}

add_kotlin_runtime_to_jar_manifest() {
    local jarfile=$1

    # we need to know the KRUN_CLASSPATH to declare in the manifest;
    # user may configure it in ~/.krunrc
    if [ -z "$KRUN_CLASSPATH" ] && [ -f "$HOME/.krunrc" ]; then
        source $HOME/.krunrc
    fi

    # ensure we have an ivy jar for ant
    if [ -z "$KRUN_CLASSPATH" ]; then
        KRUN_CLASSPATH=$(find_kotlin_runtime)
        echo "KRUN_CLASSPATH=$KRUN_CLASSPATH" >> $HOME/.krunrc
    fi

    if [ -z "$KRUN_CLASSPATH" ]; then
        echo "export KRUN_CLASSPATH or define it in ~/.krunrc" >&2
        return 1
    fi
    export KRUN_CLASSPATH

    tmpdir=$(mktemp -d)
    (
        cd $tmpdir
        unzip -qq $jarfile >/dev/null
        mv META-INF/MANIFEST.MF META-INF/MANIFEST.MF.0
        sed -i '/^\s*$/d' META-INF/MANIFEST.MF.0
        echo "Class-Path:" $KRUN_CLASSPATH > META-INF/MANIFEST.MF.1
        cat META-INF/MANIFEST.MF.0 META-INF/MANIFEST.MF.1 > META-INF/MANIFEST.MF
        echo >> META-INF/MANIFEST.MF
        rm META-INF/MANIFEST.MF.*
        jar cmf META-INF/MANIFEST.MF $jarfile .
    )
    rm -rf $tmpdir
}

ktfile=$1
if [ ! -f $ktfile ]; then
    echo "file does not exist: $ktfile" >&2
    exit 1
fi
ktfile_sha256=$(sha256sum $ktfile | head -c 64)
if [ ! -f $KRUN_CACHE/$ktfile_sha256.jar ]; then
    mkdir -p $KRUN_CACHE
    kotlinc $ktfile -d $KRUN_CACHE/$ktfile_sha256.jar
    add_kotlin_runtime_to_jar_manifest $KRUN_CACHE/$ktfile_sha256.jar
fi
java -jar $KRUN_CACHE/$ktfile_sha256.jar

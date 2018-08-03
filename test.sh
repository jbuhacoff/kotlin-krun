#!/bin/sh

# if java and kotlin are from sdkman, get the paths
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

prog=$PWD/src/main/script/krun.sh

export KRUN_CACHE=$PWD/.test

mkdir -p $KRUN_CACHE
# clear the cached .jar files
rm -rf $HOME/.krun

time $prog src/test/kotlin/hello.kt
time $prog src/test/kotlin/hello.kt

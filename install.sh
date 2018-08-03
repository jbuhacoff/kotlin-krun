#!/bin/sh

# skip if the user already has settings defined
if [ -f $HOME/.krunrc ]; then
    exit 0
fi

# register krun with binfmt_misc
is_binfmt_misc_ready=$(mount | grep "type binfmt_misc")
if [ -z "$is_binfmt_misc_ready" ]; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    echo ':kotlin:E::kt::/usr/bin/krun:OC' > /proc/sys/fs/binfmt_misc/register
fi

# set the class path for automatically compiled jars,
# we need at least kotlin-runtime.jar

# sdkman
if [ -f $HOME/.sdkman/candidates/kotlin/current/lib/kotlin-runtime.jar ]; then
    echo 'KRUN_CLASSPATH=$HOME/.sdkman/candidates/kotlin/current/lib/kotlin-runtime.jar' > $HOME/.krunrc
    exit 0
fi

# anywhere else
found=$(find / -type f -name kotlin-runtime.jar 2>/dev/null | tr ' ' ':')
if [ -n "$found" ]; then
    echo "KRUN_CLASSPATH=\"$found\"" > $HOME/.krunrc
    exit 0
fi

echo "cannot find kotlin-runtime.jar" >&2
exit 1

#!/bin/sh

# register krun with binfmt_misc
is_binfmt_misc_ready=$(mount | grep "type binfmt_misc")

# example output of mount command when binfm_misc is already mounted:
#     binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,relatime)


if [ -z "$is_binfmt_misc_ready" ]; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || exit 1
    # format is ':<type>:E::<file-ext>::<prog>:OC'
    # the command always prints this error message, even when successful:
    # echo: write error: Invalid argument
    echo ':kotlin:E::kt::/usr/bin/krun:OC' >/proc/sys/fs/binfmt_misc/register 2>/dev/null
fi

# krun

An easy way to run Kotlin scripts from the command line.

The idea came from this neat
[Cloudflare blog post](https://blog.cloudflare.com/using-go-as-a-scripting-language-in-linux/)
about `binfmt_misc` for Go-lang. After seeing that Kotlin is
[also ready for scripting](https://github.com/holgerbrandl/kscript),
I wanted to run my Kotlin scripts like ./hello.kt without having to 
compile them first to include all their dependencies in a single
binary.

Let's say you have a Kotlin script `hello.kt`:

    fun main(args: Array<String>) {
        println("Hello World!")
    }

After installing `krun` in your `PATH`, you can do this:

    krun hello.kt

If you register `krun` with `binfmt_misc` then you can also do this:

    ./hello.kt

The first time `krun` encounters a script, it compiles it with `kotlinc`.
Each subsequent time `krun` encounters the same script, it skips compiling
it and runs the `.jar` file that was compiled the first time. The "same"
script is defined by the SHA-256 digest of the script file, so the time stamp,
filename, and path are irrelevant.

The compiled `.jar` files are stored in a `~/.krun` directory. You can change
this by exporting the variable `KRUN_CACHE` with the path to a different location
that is writable. 

To compile Kotlin
code, you need to have `kotlin-runtime.jar` in the class path. If you import
any classes from other libraries, you'll need those on the class path too. You
can define the class path to use by defining a `KRUN_CLASSPATH` variable in `~/.krunrc`.
The installation script tries to find `kotlin-runtime.jar` and create the
`~/.krunrc` file for you automatically. If that file already exists, the
installation script will skip that step so it does not clobber existing
settings.

NOTE: the entries in the `KRUN_CLASSPATH` need to be space-separated, NOT colon-separated,
because they will be going into the `Class-Path` attribute of the compiled `.jar`
file's `MANIFEST.MF` file.

## Pre-requisites

The following programs need to be in the `PATH`:

* kotlinc
* java
* jar
* unzip

These are the commands to register the `.kt` scripts:

    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    echo ':kotlin:E::kt::/usr/bin/krun:OC' > /proc/sys/fs/binfmt_misc/register    

And the following standard utilities also need to be in the `PATH`:

* mktemp
* sed
* echo
* mv
* rm
* mkdir

## How to install

### From GitHub

    git clone https://github.com/jbuhacoff/kotlin-krun.git
    ( cd kotlin-krun && make install )

### From source .tgz

    tar xzf krun-0.1.tar.gz
    ( cd krun-0.1 && make install )

### In Docker

If you're going to install and test or use krun in a Docker 
container and you want to register it with binfmt_misc, create
the container with the `--privileged` option:

    make clean package
    docker run --name krun_1 --privileged -itd --env https_proxy=$https_proxy --env http_proxy=$http_proxy ubuntu:16.04 bash
    docker cp .build/krun-0.1.tar.gz krun_1:/tmp
    docker exec -it krun_1 bash -c "cd /tmp && tar xzf krun-0.1.tar.gz"
    docker exec -it krun_1 bash -c "cd /tmp/krun-0.1 && bash install-deps.sh"
    docker exec -it krun_1 bash -c "cd /tmp/krun-0.1 && bash install.sh"
    docker exec -it krun_1 bash -c "cd /tmp/krun-0.1 && bash test.sh"
    docker stop krun_1
    docker rm krun_1

## Maintenance

There's one test script that demonstrates `krun` with the cache:

    make test

This command will create the `.tar.gz` for distribution:

    make package

## Performance

Using `krun` is slightly but noticeably faster than using `kscript`. But `kscript` has a LOT more
features. It would be good if `kscript` could run with starting only a single JVM and use a class
path with the `binfmt_misc` configuration instead of packing all the dependencies into the
compiled executable.

Here are some samples from my laptop, informally:

`kscript` first time:

    time kscript hello.kt

    Hello World!
    
    real    0m3.818s
    user    0m5.644s
    sys     0m0.292s
    
`kscript` second time:

    time kscript hello.kt

    Hello World!
    
    real    0m0.425s
    user    0m0.452s
    sys     0m0.068s

`krun` first time:

    time krun hello.kt

    Hello World!
    
    real    0m3.636s
    user    0m5.444s
    sys     0m0.252s

`krun` second time:

    time krun hello.kt

    Hello World!
    
    real   0m0.100s
    user   0m0.092s
    sys    0m0.008s

The times vary, on my system the "real" time is sometimes +/- 0.010s from this
typical measurement.


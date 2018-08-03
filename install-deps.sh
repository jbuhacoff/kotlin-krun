#!/bin/sh

apt-get update
apt-get install -y curl zip

if [ ! -d "$HOME/.sdkman" ]; then
    curl -s https://get.sdkman.io | bash
fi
source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk install java
sdk install kotlin

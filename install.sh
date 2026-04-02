#!/bin/bash
SESSH=SEssh
podman build -t ssh-fedora30 .

echo 'podman run --name "ssh-fedora30" --rm -it --network host -v $HOME/.SEssh:/root/.ssh ssh-fedora30 ssh -o HostKeyAlgorithms=ssh-rsa $@' > $HOME/.local/bin/$SESSH
chmod 755 $HOME/.local/bin/$SESSH

#! /bin/bash

main() {
    mkdir -p ssh-key
    for i in {0..2}; do
        ssh-keygen -t rsa -f ssh-key/controller-$i -q -N ""
        ssh-keygen -t rsa -f ssh-key/worker-$i -q -N ""
    done
}

main
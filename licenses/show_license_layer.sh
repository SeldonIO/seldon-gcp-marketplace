#!/bin/bash

rm -rf layers && rm -f layers.tar
docker save $1 -o layers.tar
mkdir layers && tar -C layers -xvf layers.tar

pushd layers
for layer in */layer.tar; do tar -tf $layer | egrep "^licenses/" && echo $layer; done
popd

rm -rf layers && rm layers.tar

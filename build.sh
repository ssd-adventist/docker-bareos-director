#!/bin/bash

docker build --no-cache --force-rm -t ssdit/bareos-director:experimental-17.1.3 -t ssdit/bareos-director:experimental-latest -f ./Dockerfile-experimental .

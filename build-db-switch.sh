#!/bin/bash

docker build --no-cache --force-rm -t ssdit/bareos-director:db-switch -t ssdit/bareos-director:db-switch-latest -f ./Dockerfile-db-switch .

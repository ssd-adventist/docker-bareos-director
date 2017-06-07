#!/bin/bash

docker build --no-cache --force-rm -t ssdit/bareos-director-centos:16.2.5 -t ssdit/bareos-director-centos:latest -f ./Dockerfile-centos .

#!/bin/bash

helm template ./harness/ | grep docker.io | sort -u  | sed 's/^[^:]*: //g' | sed -e 's/^[ \t]*//' > images.txt

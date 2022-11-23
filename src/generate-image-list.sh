#!/bin/bash

helm template . -f override.yaml | grep docker.io | sort -u  | sed 's/^[^:]*: //g' | sed -e 's/^[ \t]*//' > images.txt

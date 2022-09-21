#!/bin/bash

dirs=("infra" "platform" "sto" "et" "ngcustomdashboard")
for dir in "${dirs[@]}"; do
  (
    cd "$dir"
    helm dep update
  )
done

helm dep update

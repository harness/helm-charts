# Data-only image for the SMP Split Proxy seed snapshot. Built by the Generate SMP FME Proxy Snapshot pipeline.
# The chart's snapshot-seed init container runs `sh -c cp /snapshot/snapshot.bin ...`, so it needs sh and cp.
FROM docker.io/busybox:1.37.0@sha256:a7dbc319b1438115a207e11930dc4bb3e643dcb3ec0bdd694bb36cd8fad289ec
COPY snapshot.bin /snapshot/snapshot.bin

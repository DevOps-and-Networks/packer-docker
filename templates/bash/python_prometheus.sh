#!/bin/sh
cd /tmp
rm -rf ./*
kubectl get nodes -l kubernetes.io/os=windows -o wide  | awk '{print $1","$6}' > raw_output.txt
kubectl get  endpoints prometheus-node-exporter -n prometheus -o yaml > old_endpoint.yaml
cp /bin/python-prometheus.py /tmp/
python3 python-prometheus.py

#!/usr/bin/env bash

/usr/src/app/bin/probe.rb --output "/data/biblioprobe.json" "/data"

/usr/bin/osv-scanner scan source -r /data --format json --output /data/osv.json

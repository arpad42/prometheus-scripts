#!/bin/bash

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

RESULTS_DIR="/var/lib/node_exporter"

[[ -z "$1" ]] && exit 1
[[ -d "/etc/prometheus/run$1" ]] || exit 1

for SCRIPT in "/etc/prometheus/run$1"/*
do
	[[ -x "$SCRIPT" ]] || continue
	(
		SHORT="${SCRIPT##*/}"
		$SCRIPT > "$RESULTS_DIR/$SHORT.prom.$$" && mv "$RESULTS_DIR/$SHORT.prom.$$" "$RESULTS_DIR/$SHORT.prom" || rm "$RESULTS_DIR/$SHORT.prom.$$"
	)
done

#!/bin/bash
source ~/.claude/otel-config
echo "{\"Authorization\": \"Bearer $OTEL_EXPORTER_OTLP_TOKEN\"}"

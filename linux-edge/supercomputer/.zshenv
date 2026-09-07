# Rust/Cargo environment
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Claude Code OTEL (endpoint sourced here; auth header via otelHeadersHelper)
[[ -f "$HOME/.claude/otel-config" ]] && source "$HOME/.claude/otel-config" && export OTEL_EXPORTER_OTLP_ENDPOINT

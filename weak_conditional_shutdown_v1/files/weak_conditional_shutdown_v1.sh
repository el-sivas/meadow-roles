#!/bin/bash

# config
shutdown_delay_minutes=5
cluster_conditional_shutdown_preventer_host="cluster-conditional-shutdown-preventer" ## FIXME: use correct host
local_prevent_file="$(mktemp)"

# logic
preventer_file_endpoint="http://${cluster_conditional_shutdown_preventer_host}:5556"

function log_info {
    echo "$(date) [INFO] $*"
}

function init_shutdown {
    reason="$*"
    log_info "Shutdown initiated, delayed for $shutdown_delay_minutes minutes, reason: $reason"
    cmd="shutdown -h $shutdown_delay_minutes"
    eval "$cmd"
    exit 0
}

function assert_condition_1 {
    log_info "1. condition: reachability of host '$cluster_conditional_shutdown_preventer_host'"
    ping -c 1 "$cluster_conditional_shutdown_preventer_host" 2>&1 || init_shutdown "ping failed to host '$cluster_conditional_shutdown_preventer_host'"
}

function assert_condition_2 {
    log_info "2. download prevent file to $local_prevent_file"
    wget -O "$local_prevent_file" "$preventer_file_endpoint" || init_shutdown "download prevent file failed"
}

function assert_condition_3 {
    log_info "3. condition: prevent file exists"
    if [ ! -f "$local_prevent_file" ]; then
        init_shutdown "prevent file does not exist"
    fi
}

function assert_condition_4 {
    log_info "4. condition: prevent file has correct content"
    content=$(cat "$local_prevent_file")
    if [ "$content" != "do not shutdown" ]; then
        init_shutdown "prevent file has incorrect content: '$content'"
    fi
}

assert_condition_1
assert_condition_2
#assert_condition_3
#assert_condition_4


log_info "all conditions passed, shutdown will not be initiated"
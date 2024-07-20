#!/bin/bash

printer="Kyocera_FS-1030D"

to_print_dir=/var/tmp/to_print
print_fails_dir=/var/tmp/print_fails

function log_info() {
    echo "$(date) [INFO] $1"
}

function error() {
    echo "$(date) [ERROR] $1" >&2
    exit 1
}

if [ -z "$(find "$to_print_dir" -name '*.pdf')" ]; then
    log_info "No PDF files found in $to_print_dir"
    exit 0
fi

for file in "$to_print_dir"/*.pdf; do
    log_info "print '$file'..."
    if ! lp -d "$printer" "$file"
    then
        mv "$file" "$print_fails_dir"
        error "print '$file' failed, moved to '$print_fails_dir"
    else
        rm "$file"
        log_info "..OK. '$file' removed"
    fi
done

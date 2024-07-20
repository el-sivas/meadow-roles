#!/bin/bash

printer="Kyocera_FS-1030D"

to_print_dir=/var/tmp/to_print
printed_dir=/var/tmp/printed
print_fails_dir=/var/tmp/print_fails

if [ -z "$(find "$to_print_dir" -name '*.pdf')" ]; then
    echo "No PDF files found in $to_print_dir"
    exit 0
fi

for file in "$to_print_dir"/*.pdf; do
    echo -n "print '$file'..."
    if ! lp -d "$printer" "$file"
    then
        mv "$file" "$print_fails_dir"
        echo "FAILED"
    else
        mv "$file" "$printed_dir"
        echo "OK"
    fi
done

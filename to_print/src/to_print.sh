#!/src/bash

printer="Kyocera_FS-1030D"

to_print_dir=/var/tmp/to_print
printed_dir=/var/tmp/printed
print_fails_dir=/var/tmp/print_fails

for file in "$to_print_dir"/*.pdf; do
    if ! lp -d "$printer" "$file"
    then
        mv "$file" "$printed_dir"
    else
        mv "$file" "$print_fails_dir"
    fi
done
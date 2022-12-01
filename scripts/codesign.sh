#!/bin/bash

set -u # forbid undefined variables
set -e # forbid command failure

readonly PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

readonly CODE_SIGN_IDENTITY=$(bash $(dirname $0)/get-codesign-identity.sh)

if [[ -z $CODE_SIGN_IDENTITY ]]; then
    echo "Skip codesign"
    exit 0
fi

#
# Define err()
#

err() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

#
# Define do_codesign
#

do_codesign() {
    echo -ne '\033[31;40m'

    set +e # allow command failure

    local entitlements=""
    if [[ -n "$2" ]]; then
        entitlements="--entitlements $2"
    fi

    codesign \
        --force \
        --deep \
        --options runtime \
        --sign "$CODE_SIGN_IDENTITY" \
        $entitlements \
        "$1" 2>&1 |
        grep -v ': replacing existing signature'

    set -e # forbid command failure

    echo -ne '\033[0m'
}

#
# Define main()
#

main() {
    if [[ ! -e "$1" ]]; then
        err "Invalid argument: '$1'"
        exit 1
    fi

    local entitlements="$2"

    if [[ -d "$1" ]]; then
        #
        # Sign with codesign
        #

        cd "$1"
        find * -name '*.app' -or -path '*/bin/*' | sort -r | while read f; do
            #
            # output message
            #

            echo -ne '\033[33;40m'
            echo "code sign $f"
            echo -ne '\033[0m'

            #
            # codesign
            #

            do_codesign "$f" "$entitlements"
        done

        #
        # Verify nested codesign (--deep)
        #

        find * -name '*.app' -or -path '*/bin/*' | sort -r | while read f; do
            echo -ne '\033[31;40m'
            codesign --verify --deep "$f"
            echo -ne '\033[0m'
        done
    else
        #
        # Sign a file
        #

        do_codesign "$1"
    fi
}

#
# Run
#

set +u # allow undefined variables
target_path="$1"
entitlements_path="$2"
set -u # forbid undefined variables

main "$target_path" "$entitlements_path"

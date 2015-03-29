#!/bin/bash
# vi: syntax=sh ts=4 expandtab

set -e
# variables
#DYNO_PATH=""
DIR="$DYNO_PATH/dynos"
LIST="$DYNO_PATH/dyno.list"

# functions
errcho() {
    >&2 echo "$*" 
    exit 1
}

_check() {
    which "$1" || errcho "Missing dependency: $1"
}

_hash() {
    $md5 <<< "$*" | cut -d' ' -f1
}

# build basic html li list into index.html
_build() {
    echo "Compile!"
}

_store() {
    hash=$1
    shift
    mkdir -p "$DIR"
    echo "$*" > "$DIR/$hash"
}

_track() {
    echo "$1 $2 $3" >> $LIST
}

# deps
md5=$(_check md5sum)
date=$(_check gdate)
edit=$(which $EDITOR || errcho 'Missing variable: $EDITOR')

# arguments and logic
now=$($date +%s)

case $# in
    0)
        _build
        ;;
    1)
        if [ ${#1} == 10 ]; then
            while read line; do
                set -- $line
                birth=$1
                death=$2
                hash=$3
                [ $death -lt $now ] && sed -i "/^$birth/d" "$LIST"
            done < $LIST
        fi
        [ ${#1} == 32 ] && $edit "$DIR/$1"
        ;;
    *)
        # default is die in +5 years
        die=$($date -d '+5 year' "+%s")
        content="$*"
        hash=$(_hash "$content")
        _track "$now" "$die" "$hash"
        _store "$hash" "$content"
        ;;
esac

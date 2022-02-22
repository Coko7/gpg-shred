#!/bin/bash

NAME="gpg-shred"
GPG_OPTIONS="--no-symkey-cache"

function showHelp() {
    echo "gpg-shred 1.0.0"
    echo "Copyright (C) 2022 Coko7"
    echo "This is free software: you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."
    echo ""
    echo "Usage: $NAME [OPTION]... FILE..."
    echo "Use gpg to encrypt or decrypt file with the added bonus of shredding the original file."
}

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    echo "$NAME: usage error: incorrect argument count (Try '$NAME --help')"
    exit 1
fi

case $1 in
"-h" | "--help")
    showHelp
    ;;
"-e")
    echo "$NAME: encrypting file with gpg symmetric key..."

    if [ -z "$2" ]; then
        echo "$NAME: encrypting: missing file name"
        exit 1
    fi

    FILE=$2
    if [ ! -f "$FILE" ]; then
        echo "$NAME: encrypting: can't open '$FILE': No such file or directory"
        exit 1
    fi

    gpg --symmetric "$GPG_OPTIONS" "$FILE" && {
        echo "gpg -c on $FILE successful" >>logfile
        shred -u "$FILE" && {
            echo "shred on $FILE successful" >>logfile
        } || {
            echo "Error, shred on $FILE failed" >>logfile
        }
    } || {
        echo "Error, $FILE did not encrypt" >>logfile
    }
    ;;
"-d")
    echo "$NAME: decrypting file with gpg symmetric key..."

    if [ -z "$2" ]; then
        echo "$NAME: decrypting: missing file name"
        exit 1
    fi

    FILE=$2
    if [ ! -f "$FILE" ]; then
        echo "$NAME: decrypting: can't open '$FILE': No such file or directory"
        exit 1
    fi

    # Get filename without '.gpg' extension
    OUTPUT=$(basename $FILE .gpg)

    gpg "$GPG_OPTIONS" --output "$OUTPUT" -d "$FILE" && {
        echo "gpg -d on $FILE successful" >>logfile
        shred -u "$FILE" && {
            echo "shred on $FILE successful" >>logfile
        } || {
            echo "Error, shred on $FILE failed" >>logfile
        }
    } || {
        echo "Error, $FILE did not decrypt" >>logfile
    }

    ;;
*)
    printf "$NAME: invalid option -- '$1'\nTry '$NAME --help' for more information."
    exit 1
    ;;
esac

#!/bin/sh

cat "$1" | sed -e s/pick/e/g > ".rebase"
mv ".rebase" "$1"
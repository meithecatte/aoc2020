#!/bin/sh
echo $((2#$(tr FBLR 0101 < input | sort | tail -n1)))

prev=""
for v in $(tr FBLR 0101 < input | sort); do
    n=$((2#$v))
    if [ $(($n-2)) == "$prev" ]; then
        echo $(($n-1))
    fi
    prev=$n
done

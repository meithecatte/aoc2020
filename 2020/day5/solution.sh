#!/bin/sh
echo $((2#$(tr FBLR 0101 < input | sort | tail -n1)))

#!/bin/sh

grep -v '+++' | grep -v -e '---' | grep -v '@@' | grep '^[<>+-]'

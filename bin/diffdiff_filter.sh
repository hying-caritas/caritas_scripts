#!/bin/bash

grep -v '+++' | grep -v -e '---' | grep -v '@@' | grep '^[<>+-]'

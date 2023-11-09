#!/bin/bash

# This script is executed when either the mode changes,
# or the commandline changes

# Here I am simply passing the event to sketchybar, where an item handles it.

sketchybar --trigger svim_update MODE="$MODE" CMDLINE="$CMDLINE"

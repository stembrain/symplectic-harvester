#!/bin/bash

export HARVESTER_INSTALL_DIR=/Users/ieb/Caret/vivo/vivo-harvester-code
export EXTENSION_INSTALL_DIR=/Users/ieb/Caret/vivo/symplectic
export DATE=`date +%Y-%m-%d'T'%T`

# Add harvester binaries to path for execution
# The tools within this script refer to binaries supplied within the harvester
#	Since they can be located in another directory their path should be
#	included within the classpath and the path environment variables.
export PATH=$PATH:$HARVESTER_INSTALL_DIR/bin
export CLASSPATH=$CLASSPATH:$EXTENSION_INSTALL_DIR/build/classes:$EXTENSION_INSTALL_DIR/build/symplectic-harvester.jar
export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/bin/harvester.jar:$HARVESTER_INSTALL_DIR/bin/dependency/*
export CLASSPATH=$CLASSPATH:$HARVESTER_INSTALL_DIR/build/harvester.jar:$HARVESTER_INSTALL_DIR/build/dependency/*

set -e
default_query="select ?s ?p ?v where { ?s ?p ?v }"
query=${2:-$default_query}


harvester-jenaconnect -j $1  -q "$query"

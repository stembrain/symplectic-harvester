#!/bin/bash
#  This code is based on the code from the Vivo Harvester team.
#  Modifications Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
#  Please see the LICENSE file for more details

. ./symplectic-tools.config

set -e
default_query="select ?s ?p ?v where { ?s ?p ?v }"
query=${2:-$default_query}


harvester-jenaconnect -j $1  -q "$query"

#!/bin/bash 

#Copyright (c) 2010-2011 VIVO Harvester Team. For full list of contributors, please see the AUTHORS file provided.
#All rights reserved.
#This program and the accompanying materials are made available under the terms of the new BSD license which accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html
#  
#  Modifications Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
#  Please see the LICENSE file for more details

. ./symplectic-tools.config

# Exit on first error
# The -e flag prevents the script from continuing even though a tool fails.
#	Continuing after a tool failure is undesirable since the harvested
#	data could be rendered corrupted and incompatible.
set -e

BASE_URI=`grep 'xsl:variable name="baseURI"' symplectic-to-vivo.datamap.xsl  | sed 's/.*>\(.*\)<.*/\1/'`
if [ a$BASE_URI = "ahttp://changeme/to/match/vivo/deploy/properties" ]; then
   echo Please change the baseURI settings in symplectic-to-vivo.datamap.xsl to match your vivo deploy.properties
   grep 'xsl:variable name="baseURI"' symplectic-to-vivo.datamap.xsl
   exit
fi
echo Base URI is $BASE_URI



# Supply the location of the detailed log file which is generated during the script.
#	If there is an issue with a harvest, this file proves invaluable in finding
#	a solution to the problem. It has become common practice in addressing a problem
#	to request this file. The passwords and usernames are filtered out of this file
#	to prevent these logs from containing sensitive information.
echo "Full Logging in $HARVEST_NAME.$DATE.log"
if [ ! -d logs ]; then
  mkdir logs
fi
cd logs
touch $HARVEST_NAME.$DATE.log
ln -sf $HARVEST_NAME.$DATE.log $HARVEST_NAME.latest.log
cd ..


# Execute Translate
# This is the part of the script where the input data is transformed into valid RDF
#   Translate will apply an xslt file to the fetched data which will result in the data 
#   becoming valid RDF in the VIVO ontology
harvester-xsltranslator -X xsltranslator.config.xml


cd data/translated-records
find . -size 0 -exec rm .metadata/{} \;
find . -size 0 -exec rm {} \;
find . -name 'grant*' -exec rm {} \;
cd ../../

# Execute Transfer to import from record handler into local temp model
# From this stage on the script places the data into a Jena model. A model is a
#	data storage structure similar to a database, but in RDF.
# The harvester tool Transfer is used to move/add/remove/dump data in models.
# For this call on the transfer tool:
# -s refers to the source translated records file, which was just produced by the translator step
# -o refers to the destination model for harvested data
# -d means that this call will also produce a text dump file in the specified location 
# dont add to harvested data if not scoring harvester-transfer -s translated-records.config.xml -o harvested-data.model.xml -d data/harvested-data/imported-records.rdf.xml
harvester-transfer -s translated-records.config.xml -o matched-data.model.xml -d data/matched-data/imported-records.rdf.xml





# Perform an update
# The harvester maintains copies of previous harvests in order to perform the same harvest twice
#   but only add the new statements, while removing the old statements that are no longer
#   contained in the input data. This is done in several steps of finding the old statements,
#   then the new statements, and then applying them to the Vivo main model.

# Find Subtractions
# When making the previous harvest model agree with the current harvest, the statements that exist in
#	the previous harvest but not in the current harvest need to be identified for removal.
harvester-diff -X diff-subtractions.config.xml

# Find Additions
# When making the previous harvest model agree with the current harvest, the statements that exist in
#	the current harvest but not in the previous harvest need to be identified for addition.
harvester-diff -X diff-additions.config.xml

echo 'Data is ready for ingest, please run rin-ingest-only.sh to perform that step'

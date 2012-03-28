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

#clear old data
# For a fresh harvest, the removal of the previous information maintains data integrity.
#	If you are continuing a partial run or wish to use the old and already retrieved
#	data, you will want to comment out this line since it could prevent you from having
# 	the required harvest data.  
#rm -rf data
#cp -r datasafe data

# Execute Fetch
# This stage of the script is where the information is gathered together into one local
#	place to facilitate the further steps of the harvest. The data is stored locally
#	in a format based off of the source. The format is a form of RDF but not in the VIVO ontology
# The symplecticFetch tool in particular takes the data from the chosen source described in its
#	configuration XML file and places it into record set in the flat RDF directly 
#	related to the rows, columns and tables described in the target database.
harvester-symplecticfetch -X symplecticfetch.config.xml 

# Execute Translate
# This is the part of the script where the input data is transformed into valid RDF
#   Translate will apply an xslt file to the fetched data which will result in the data 
#   becoming valid RDF in the VIVO ontology
harvester-xsltranslator -X xsltranslator.config.xml

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

# Apply Subtractions to Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-subtractions.rdf.xml -m
# Apply Additions to Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-additions.rdf.xml

# Now that the changes have been applied to the previous harvest and the harvested data in vivo
#	agree with the previous harvest, the changes are now applied to the vivo model.
# Apply Subtractions to VIVO model
harvester-transfer -o vivo.model.xml -r data/vivo-subtractions.rdf.xml -m
# Apply Additions to VIVO model
harvester-transfer -o vivo.model.xml -r data/vivo-additions.rdf.xml

#Output some counts
PUBS=`cat data/vivo-additions.rdf.xml | grep 'http://vivoweb.org/ontology/core#InformationResource' | wc -l`
AUTHORS=`cat data/vivo-additions.rdf.xml | grep 'http://xmlns.com/foaf/0.1/Person' | wc -l`
AUTHORSHIPS=`cat data/vivo-additions.rdf.xml | grep Authorship | wc -l`
echo "Imported $PUBS publications, $AUTHORS authors, and $AUTHORSHIPS authorships"

echo 'Harvest completed successfully'

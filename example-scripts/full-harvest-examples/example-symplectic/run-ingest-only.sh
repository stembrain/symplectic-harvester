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


# Apply Subtractions to Previous model
harvester-transfer -o previous-harvest.model.xml -i subtracted-data.model.xml -m
# Apply Additions to Previous model
harvester-transfer -o previous-harvest.model.xml -i added-data.model.xml

# Now that the changes have been applied to the previous harvest and the harvested data in vivo
#	agree with the previous harvest, the changes are now applied to the vivo model.
# Apply Subtractions to VIVO model
harvester-transfer -o vivo.model.xml -i subtracted-data.model.xml -m
# Apply Additions to VIVO model
harvester-transfer -o vivo.model.xml -r added-data.model.xml

#Output some counts
PUBS=`cat data/vivo-additions.rdf.xml | grep 'http://vivoweb.org/ontology/core#InformationResource' | wc -l`
AUTHORS=`cat data/vivo-additions.rdf.xml | grep 'http://xmlns.com/foaf/0.1/Person' | wc -l`
AUTHORSHIPS=`cat data/vivo-additions.rdf.xml | grep Authorship | wc -l`
echo "Imported $PUBS publications, $AUTHORS authors, and $AUTHORSHIPS authorships"

harvester-smush -r -i vivo.model.xml -P http://www.symplectic.co.uk/vivo/smush -n $BASE_URI

echo "Smush completed"

echo 'Harvest completed successfully'

#!/bin/bash

#Copyright (c) 2010-2011 VIVO Harvester Team. For full list of contributors, please see the AUTHORS file provided.
#All rights reserved.
#This program and the accompanying materials are made available under the terms of the new BSD license which accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html
#
#  Modifications Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
#  Please see the LICENSE file for more details

. symplectic-tools.config

# Exit on first error
# The -e flag prevents the script from continuing even though a tool fails.
#	Continuing after a tool failure is undesirable since the harvested
#	data could be rendered corrupted and incompatible.
set -e

# Supply the location of the detailed log file which is generated during the script.
#	If there is an issue with a harvest, this file proves invaluable in finding
#	a solution to the problem. I has become common practice in addressing a problem
#	to request this file. The passwords and user-names are filter out of this file
#	To prevent these logs from containing sensitive information.
echo "Full Logging in $HARVEST_NAME.$DATE.log"

# Be aware that the additions file may have data which was duplicating existing triples and
#	removing the additions file will result in removing the previously existing triples.
#	To prevent post-removal data issues inspections and edits of the additions may need
#	to be done.


echo "addition node count to be removed: " `grep -c "<rdf:Description" data/vivo-additions.rdf.xml`

echo "subtraction node count to be added: " `grep -c "<rdf:Description" data/vivo-subtractions.rdf.xml`


# During the reverse process the previous harvest model needs to be adjusted when the
#	vivo model is also adjusted. This keeps the previous model as a mirror of the changes
#	the the harvester has ever done to the vivo model. 
# Remove Additions from Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-additions.rdf.xml -R RDF/XML -m
# Remove Subtractions from Previous model
harvester-transfer -o previous-harvest.model.xml -r data/vivo-subtractions.rdf.xml -R RDF/XML 

# Now that the changes have been applied to the previous harvest and the harvested data in vivo
#	should agree with the previous harvest, the changes are now applied to the vivo model.
# Remove Additions from VIVO for pre-1.2 versions
harvester-transfer -o vivo.model.xml -r data/vivo-additions.rdf.xml -R RDF/XML -m
# Remove Subtractions from VIVO for pre-1.2 versions
harvester-transfer -o vivo.model.xml -r data/vivo-subtractions.rdf.xml -R RDF/XML

echo 'Harvest reversal completed successfully'

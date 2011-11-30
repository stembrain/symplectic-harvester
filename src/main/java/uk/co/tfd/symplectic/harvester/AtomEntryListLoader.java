/*
 *  Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
 *  Please see the LICENSE file for more details
 */

package uk.co.tfd.symplectic.harvester;

import org.w3c.dom.Node;

/**
 * Generic interface to load Atom Entries
 * @author ieb
 *
 */
public interface AtomEntryListLoader {


	
	void addPage(Node item) throws AtomEntryLoadException;



}
